import UIKit
import RxSwift
import Moya

enum BidCheckingError: ErrorType {
    case PollingExceeded
}

class BidCheckingNetworkModel: NSObject {

    private var pollInterval = NSTimeInterval(1)
    private var maxPollRequests = 20
    private var pollRequests = 0

    // inputs
    unowned let fulfillmentController: FulfillmentController

    // outputs
    var bidIsResolved = Variable(false)
    var isHighestBidder = Variable(false)
    var reserveNotMet = Variable(false)

    private var mostRecentSaleArtwork: SaleArtwork?

    init(fulfillmentController: FulfillmentController) {
        self.fulfillmentController = fulfillmentController
    }

    func waitForBidResolution (bidderPositionId: String) -> Observable<Void> {
        return self
            .pollForUpdatedBidderPosition(bidderPositionId)
            .then { [weak self] in
                guard let me = self else { return empty() }

                return me
                    .getUpdatedSaleArtwork()
                    .flatMap { [weak self] saleArtwork -> Observable<Void> in
                        guard let me = self else { return empty() }

                        // This is an updated model – hooray!
                        me.mostRecentSaleArtwork = saleArtwork
                        me.fulfillmentController.bidDetails.saleArtwork?.updateWithValues(saleArtwork)
                        me.reserveNotMet.value = ReserveStatus.initOrDefault(saleArtwork.reserveStatus).reserveNotMet

                        return just()
                    }
                    .doOnError { _ in
                        logger.log("Bidder position was processed but corresponding saleArtwork was not found")
                    }
                    .catchErrorJustReturn()
                    .flatMap { [weak self] _ -> Observable<Void> in
                        // TODO: adjust logic to use parameter instead of instance variable

                        guard let me = self else { return empty() }

                        return me.checkForMaxBid()
                }
            } .doOnNext { _ in
                self.bidIsResolved.value = true
                
                // If polling fails, we can still show bid confirmation. Do not error.
            }.catchErrorJustReturn()
    }
    
    private func pollForUpdatedBidderPosition(bidderPositionId: String) -> Observable<Void> {
        let updatedBidderPosition = getUpdatedBidderPosition(bidderPositionId)
            .flatMap { [weak self] bidderPositionObject -> Observable<Void> in
                self?.pollRequests++

                logger.log("Polling \(self?.pollRequests) of \(self?.maxPollRequests) for updated sale artwork")

                // TODO: handle the case where the user was already the highest bidder
                if let processedAt = bidderPositionObject.processedAt {
                    logger.log("BidPosition finished processing at \(processedAt), proceeding...")
                    return just()
                } else {
                    // The backend hasn't finished processing the bid yet

                    guard (self?.pollRequests ?? 0) < (self?.maxPollRequests ?? 0) else {
                        // We have exceeded our max number of polls, fail.
                        throw BidCheckingError.PollingExceeded
                    }

                    // We didn't get an updated value, so let's try again.
                    interval(self?.pollInterval ?? 1, MainScheduler.sharedInstance)
                        .take(1)
                        .map(void)
                        .then {
                            return self?.pollForUpdatedBidderPosition(bidderPositionId)
                    }
                }
        }
        
        return interval(pollInterval, MainScheduler.sharedInstance)
            .take(1)
            .map(void)
            .then { updatedBidderPosition }
    }

    private func checkForMaxBid() -> Observable<Void> {
        return getMyBidderPositions()
            .doOnNext{ [weak self] newBidderPositions -> Void in
                guard let me = self else { return }

                if let topBidID = me.mostRecentSaleArtwork?.saleHighestBid?.id {
                    for position in newBidderPositions where position.highestBid?.id == topBidID {
                        me.isHighestBidder.value = true
                    }
                }
            }
            .map(void)
    }

    private func getMyBidderPositions() -> Observable<[BidderPosition]> {
        let artworkID = fulfillmentController.bidDetails.saleArtwork!.artwork.id;
        let auctionID = fulfillmentController.bidDetails.saleArtwork!.auctionID!

        let endpoint: ArtsyAPI = ArtsyAPI.MyBidPositionsForAuctionArtwork(auctionID: auctionID, artworkID: artworkID)
        return fulfillmentController
            .loggedInProvider!
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObjectArray(BidderPosition)
    }

    private func getUpdatedSaleArtwork() -> Observable<SaleArtwork> {

        let artworkID = fulfillmentController.bidDetails.saleArtwork!.artwork.id;
        let auctionID = fulfillmentController.bidDetails.saleArtwork!.auctionID!

        let endpoint: ArtsyAPI = ArtsyAPI.AuctionInfoForArtwork(auctionID: auctionID, artworkID: artworkID)
        return fulfillmentController
            .loggedInProvider!
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObject(SaleArtwork)
    }
    
    private func getUpdatedBidderPosition(bidderPositionId: String) -> Observable<BidderPosition> {
        let endpoint: ArtsyAPI = ArtsyAPI.MyBidPosition(id: bidderPositionId)
        return fulfillmentController
            .loggedInProvider!
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObject(BidderPosition)
    }
}
