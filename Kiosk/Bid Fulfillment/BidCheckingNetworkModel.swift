import UIKit
import RxSwift
import Moya

enum BidCheckingError: String {
    case PollingExceeded
}

extension BidCheckingError: ErrorType { }

protocol BidCheckingNetworkModelType {
    var bidDetails: BidDetails { get }

    var bidIsResolved: Variable<Bool> { get }
    var isHighestBidder: Variable<Bool> { get }
    var reserveNotMet: Variable<Bool> { get }

    func waitForBidResolution (bidderPositionId: String, provider: AuthorizedNetworking) -> Observable<Void>
}

class BidCheckingNetworkModel: NSObject, BidCheckingNetworkModelType {

    private var pollInterval = NSTimeInterval(1)
    private var maxPollRequests = 20
    private var pollRequests = 0

    // inputs
    let provider: Networking
    let bidDetails: BidDetails

    // outputs
    var bidIsResolved = Variable(false)
    var isHighestBidder = Variable(false)
    var reserveNotMet = Variable(false)

    private var mostRecentSaleArtwork: SaleArtwork?

    init(provider: Networking, bidDetails: BidDetails) {
        self.provider = provider
        self.bidDetails = bidDetails
    }

    func waitForBidResolution (bidderPositionId: String, provider: AuthorizedNetworking) -> Observable<Void> {
        return self
            .pollForUpdatedBidderPosition(bidderPositionId, provider: provider)
            .then {

                return self.getUpdatedSaleArtwork()
                    .flatMap { saleArtwork -> Observable<Void> in

                        // This is an updated model – hooray!
                        self.mostRecentSaleArtwork = saleArtwork
                        self.bidDetails.saleArtwork?.updateWithValues(saleArtwork)
                        self.reserveNotMet.value = ReserveStatus.initOrDefault(saleArtwork.reserveStatus).reserveNotMet

                        return just()
                    }
                    .doOnError { _ in
                        logger.log("Bidder position was processed but corresponding saleArtwork was not found")
                    }
                    .catchErrorJustReturn()
                    .flatMap { _ -> Observable<Void> in
                        return self.checkForMaxBid(provider)
                }
            } .doOnNext { _ in
                self.bidIsResolved.value = true
                
                // If polling fails, we can still show bid confirmation. Do not error.
            }.catchErrorJustReturn()
    }
    
    private func pollForUpdatedBidderPosition(bidderPositionId: String, provider: AuthorizedNetworking) -> Observable<Void> {
        let updatedBidderPosition = getUpdatedBidderPosition(bidderPositionId, provider: provider)
            .flatMap { bidderPositionObject -> Observable<Void> in
                self.pollRequests++

                logger.log("Polling \(self.pollRequests) of \(self.maxPollRequests) for updated sale artwork")

                if let processedAt = bidderPositionObject.processedAt {
                    logger.log("BidPosition finished processing at \(processedAt), proceeding...")
                    return just()
                } else {
                    // The backend hasn't finished processing the bid yet

                    guard self.pollRequests < self.maxPollRequests else {
                        // We have exceeded our max number of polls, fail.
                        throw BidCheckingError.PollingExceeded
                    }

                    // We didn't get an updated value, so let's try again.
                    return interval(self.pollInterval, MainScheduler.sharedInstance)
                        .take(1)
                        .map(void)
                        .then {
                            return self.pollForUpdatedBidderPosition(bidderPositionId, provider: provider)
                    }
                }
        }
        
        return interval(pollInterval, MainScheduler.sharedInstance)
            .take(1)
            .map(void)
            .then { updatedBidderPosition }
    }

    private func checkForMaxBid(provider: AuthorizedNetworking) -> Observable<Void> {
        return getMyBidderPositions(provider)
            .doOnNext{ newBidderPositions in

                if let topBidID = self.mostRecentSaleArtwork?.saleHighestBid?.id {
                    for position in newBidderPositions where position.highestBid?.id == topBidID {
                        self.isHighestBidder.value = true
                    }
                }
            }
            .map(void)
    }

    private func getMyBidderPositions(provider: AuthorizedNetworking) -> Observable<[BidderPosition]> {
        let artworkID = bidDetails.saleArtwork!.artwork.id;
        let auctionID = bidDetails.saleArtwork!.auctionID!

        let endpoint = ArtsyAuthenticatedAPI.MyBidPositionsForAuctionArtwork(auctionID: auctionID, artworkID: artworkID)
        return provider
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObjectArray(BidderPosition)
    }

    private func getUpdatedSaleArtwork() -> Observable<SaleArtwork> {

        let artworkID = bidDetails.saleArtwork!.artwork.id;
        let auctionID = bidDetails.saleArtwork!.auctionID!

        let endpoint: ArtsyAPI = ArtsyAPI.AuctionInfoForArtwork(auctionID: auctionID, artworkID: artworkID)
        return provider
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObject(SaleArtwork)
    }
    
    private func getUpdatedBidderPosition(bidderPositionId: String, provider: AuthorizedNetworking) -> Observable<BidderPosition> {
        let endpoint = ArtsyAuthenticatedAPI.MyBidPosition(id: bidderPositionId)
        return provider
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObject(BidderPosition)
    }
}
