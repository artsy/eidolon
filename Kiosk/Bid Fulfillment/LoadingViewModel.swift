import Foundation
import ARAnalytics
import RxSwift

/// Encapsulates activities of the LoadingViewController.
class LoadingViewModel: NSObject {
    let placingBid: Bool
    let bidderNetworkModel: BidderNetworkModel

    lazy var placeBidNetworkModel: PlaceBidNetworkModel = {
        return PlaceBidNetworkModel(fulfillmentController: self.bidderNetworkModel.fulfillmentController)
    }()
    lazy var bidCheckingModel: BidCheckingNetworkModel = { 
        return BidCheckingNetworkModel(fulfillmentController: self.bidderNetworkModel.fulfillmentController)
    }()

    let createdNewBidder = Variable(false)
    let bidIsResolved = Variable(false)
    let isHighestBidder = Variable(false)
    let reserveNotMet = Variable(false)

    var bidDetails: BidDetails {
        return bidderNetworkModel.fulfillmentController.bidDetails
    }

    init(bidNetworkModel: BidderNetworkModel, placingBid: Bool, actionsCompleteSignal: Observable<Void>) {
        self.bidderNetworkModel = bidNetworkModel
        self.placingBid = placingBid

        super.init()

        // Set up bindings.
        [
            (bidderNetworkModel.createdNewUser, createdNewBidder),
            (bidCheckingModel.bidIsResolved.asObservable(), bidIsResolved),
            (bidCheckingModel.isHighestBidder.asObservable(), isHighestBidder),
            (bidCheckingModel.reserveNotMet.asObservable(), reserveNotMet)
        ].forEach { pair in
            pair.0
                .takeUntil(actionsCompleteSignal)
                .bindTo(pair.1)
                .addDisposableTo(rx_disposeBag)
        }
    }

    /// Encapsulates essential activities of the LoadingViewController, including:
    /// - Registering new users
    /// - Placing bids for users
    /// - Polling for bid results
    func performActions() -> Observable<Void> {
        return bidderNetworkModel
            .createOrGetBidder()
            .map(void)
            .then { [weak self] () -> Observable<Void> in
                guard let me = self else { return empty() }
                guard me.placingBid else {
                    ARAnalytics.event("Registered New User Only")
                    return empty()
                }

                ARAnalytics.event("Started Placing Bid", withProperties: ["id": me.bidDetails.saleArtwork?.artwork.id ?? ""])

                return me
                    .placeBidNetworkModel
                    .bidSignal()
                    .map(void)
            }
            .flatMap { [weak self] position -> Observable<Void> in
                guard let me = self else { return empty() }
                guard me.placingBid else { return empty() }

                return me.bidCheckingModel.waitForBidResolution(position).map(void)
            }
    }
}
