import UIKit
import RxSwift
import Moya

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

    func waitForBidResolution (bidderPositionId: String) -> RACSignal {
        return self.pollForUpdatedBidderPosition(bidderPositionId).then { [weak self] in
            guard let me = self else { return RACSignal.empty() }

            return me.getUpdatedSaleArtwork().flattenMap { [weak self] (saleObject) -> RACStream! in
                guard let me = self else { return RACSignal.empty() }
                
                // This is an updated model – hooray!
                if let saleArtwork = saleObject as? SaleArtwork {
                    me.mostRecentSaleArtwork = saleArtwork
                    me.fulfillmentController.bidDetails.saleArtwork?.updateWithValues(saleArtwork)
                    me.reserveNotMet = ReserveStatus.initOrDefault(saleArtwork.reserveStatus).reserveNotMet
                    return RACSignal.`return`(saleArtwork)
                } else {
                    logger.log("Bidder position was processed but corresponding saleArtwork was not found")
                    return RACSignal.empty()
                }
            }.flattenMap { [weak self] mostRecentSaleArtwork in
                // TODO: adjust logic to use parameter instead of instance variable

                guard let me = self else { return RACSignal.empty() }

                return me.checkForMaxBid()
            }
        } .doNext { _ in
            self.bidIsResolved = true
            return

        // If polling fails, we can still show bid confirmation. Do not error.
        } .catchTo( RACSignal.empty() )
    }
    
    private func pollForUpdatedBidderPosition(bidderPositionId: String) -> RACSignal {
        let updatedBidderPosition = getUpdatedBidderPosition(bidderPositionId).flattenMap { [weak self] bidderPositionObject in
            self?.pollRequests++
            
            logger.log("Polling \(self?.pollRequests) of \(self?.maxPollRequests) for updated sale artwork")
            
            // TODO: handle the case where the user was already the highest bidder
            if let processedAt = (bidderPositionObject as? BidderPosition)?.processedAt {
                logger.log("BidPosition finished processing at \(processedAt), proceeding...")
                
                return RACSignal.`return`(processedAt)
            } else {
                // The backend hasn't finished processing the bid yet
                
                if (self?.pollRequests ?? 0) >= (self?.maxPollRequests ?? 0) {
                    // We have exceeded our max number of polls, fail.
                    return RACSignal.error(nil)
                    
                } else {
                    // We didn't get an updated value, so let's try again.
                    return RACSignal.empty().delay(self?.pollInterval ?? 1).then({ () -> RACSignal! in
                        return self?.pollForUpdatedBidderPosition(bidderPositionId)
                    })
                }
            }
        }
        
        return RACSignal.empty().delay(pollInterval).then { updatedBidderPosition }
    }

    private func checkForMaxBid() -> RACSignal {
        return self.getMyBidderPositions().doNext { [weak self] (newBidderPositions) -> Void in
            let newBidderPositions = newBidderPositions as? [BidderPosition]
            if let topBidID = self?.mostRecentSaleArtwork?.saleHighestBid?.id {
                for position in newBidderPositions! {
                    if position.highestBid?.id == topBidID {
                        self?.isHighestBidder = true
                    }
                }
            } else {
                RACSignal.error(nil)
            }
        }
    }


    private func getMyBidderPositions() -> RACSignal {
        let artworkID = fulfillmentController.bidDetails.saleArtwork!.artwork.id;
        let auctionID = fulfillmentController.bidDetails.saleArtwork!.auctionID!

        let endpoint: ArtsyAPI = ArtsyAPI.MyBidPositionsForAuctionArtwork(auctionID: auctionID, artworkID: artworkID)
        return fulfillmentController.loggedInProvider!.request(endpoint).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(BidderPosition.self)
    }

    private func getUpdatedSaleArtwork() -> RACSignal {

        let artworkID = fulfillmentController.bidDetails.saleArtwork!.artwork.id;
        let auctionID = fulfillmentController.bidDetails.saleArtwork!.auctionID!

        let endpoint: ArtsyAPI = ArtsyAPI.AuctionInfoForArtwork(auctionID: auctionID, artworkID: artworkID)
        return fulfillmentController.loggedInProvider!.request(endpoint).filterSuccessfulStatusCodes().mapJSON().mapToObject(SaleArtwork.self)
    }
    
    private func getUpdatedBidderPosition(bidderPositionId: String) -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.MyBidPosition(id: bidderPositionId)
        return fulfillmentController.loggedInProvider!.request(endpoint).filterSuccessfulStatusCodes().mapJSON().mapToObject(BidderPosition.self)
    }
}
