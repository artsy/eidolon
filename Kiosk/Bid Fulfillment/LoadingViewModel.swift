import Foundation
import ARAnalytics
import ReactiveCocoa
import Swift_RAC_Macros

/// Encapsulates activities of the LoadingViewController.
class LoadingViewModel: NSObject {
    let placingBid: Bool
    let bidderNetworkModel: BidderNetworkModel

    lazy var placeBidNetworkModel: PlaceBidNetworkModel = {
        return PlaceBidNetworkModel(fulfillmentController: self.bidderNetworkModel.fulfillmentController)
    }()
    lazy var bidCheckingModel: BidCheckingNetworkModel = { () -> BidCheckingNetworkModel in
        return BidCheckingNetworkModel(fulfillmentController: self.bidderNetworkModel.fulfillmentController)
    }()

    dynamic var createdNewBidder = false
    dynamic var bidIsResolved = false
    dynamic var isHighestBidder = false
    dynamic var reserveNotMet = false
    var bidDetails: BidDetails {
        return bidderNetworkModel.fulfillmentController.bidDetails
    }

    init(bidNetworkModel: BidderNetworkModel, placingBid: Bool) {
        self.bidderNetworkModel = bidNetworkModel
        self.placingBid = placingBid

        super.init()

        RAC(self, "createdNewBidder") <~ RACObserve(bidderNetworkModel, "createdNewBidder")
        RAC(self, "bidIsResolved") <~ RACObserve(bidCheckingModel, "bidIsResolved")
        RAC(self, "isHighestBidder") <~ RACObserve(bidCheckingModel, "isHighestBidder")
        RAC(self, "reserveNotMet") <~ RACObserve(bidCheckingModel, "reserveNotMet")
    }

    /// Encapsulates essential activities of the LoadingViewController, including:
    /// - Registering new users
    /// - Placing bids for users
    /// - Polling for bid results
    func performActions() -> RACSignal {
        return bidderNetworkModel.createOrGetBidder().then { [weak self] () -> RACSignal in
            if self?.placingBid == false {
                ARAnalytics.event("Registered New User Only")
                return RACSignal.empty()
            }

            if let strongSelf = self {
                ARAnalytics.event("Started Placing Bid")
                return strongSelf.placeBidNetworkModel.bidSignal().ignore(nil)
            } else {
                return RACSignal.empty()
            }

        }.flattenMap { [weak self] (position) in

            if self == nil || self?.placingBid == false {
                return RACSignal.empty()
            }
            
            return self!.bidCheckingModel.waitForBidResolution(position as! String)
        }
    }
}
