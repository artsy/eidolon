import Foundation
import ARAnalytics
import ReactiveCocoa
import Swift_RAC_Macros

/// Encapsulates activities of the LoadingViewController.
public class LoadingViewModel: NSObject {
    public let placingBid: Bool
    public let bidderNetworkModel: BidderNetworkModel

    public lazy var placeBidNetworkModel: PlaceBidNetworkModel = {
        return PlaceBidNetworkModel(fulfillmentController: self.bidderNetworkModel.fulfillmentController)
    }()
    public lazy var bidCheckingModel: BidCheckingNetworkModel = { () -> BidCheckingNetworkModel in
        return BidCheckingNetworkModel(fulfillmentController: self.bidderNetworkModel.fulfillmentController)
    }()

    public dynamic var createdNewBidder = false
    public dynamic var bidIsResolved = false
    public dynamic var isHighestBidder = false
    public dynamic var reserveNotMet = false
    public var bidDetails: BidDetails {
        return bidderNetworkModel.fulfillmentController.bidDetails
    }

    public init(bidNetworkModel: BidderNetworkModel, placingBid: Bool) {
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
    public func performActions() -> RACSignal {
        return bidderNetworkModel.createOrGetBidder().then { [weak self] () -> RACSignal in
            if self?.placingBid == false {
                ARAnalytics.event("Registered New User Only")
                return RACSignal.empty()
            }

            if let strongSelf = self {
                ARAnalytics.event("Started Placing Bid")
                return strongSelf.placeBidNetworkModel.bidSignal(strongSelf.bidderNetworkModel.fulfillmentController.bidDetails)
            } else {
                return RACSignal.empty()
            }

        }.then { [weak self] (_) in

            if self == nil || self?.placingBid == false {
                return RACSignal.empty()
            }
            
            return self!.bidCheckingModel.waitForBidResolution()
        }
    }
}
