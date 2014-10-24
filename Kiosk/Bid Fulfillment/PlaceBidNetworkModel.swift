import UIKit

class PlaceBidNetworkModel: NSObject {

    var fulfillmentNav:FulfillmentNavigationController!
    var bidderPosition:BidderPosition?

    func bidSignal(bidDetails: BidDetails) -> RACSignal {

        let saleArtwork = bidDetails.saleArtwork
        let cents = String(bidDetails.bidAmountCents! as Int)
        return self.bidOnSaleArtwork(saleArtwork!, bidAmountCents: cents)

    }

    func provider() -> ReactiveMoyaProvider<ArtsyAPI>  {
        if let provider = fulfillmentNav.loggedInProvider {
            return provider
        }
        return Provider.sharedProvider
    }

    func bidOnSaleArtwork(saleArtwork: SaleArtwork, bidAmountCents: String) -> RACSignal {
        let bidEndpoint: ArtsyAPI = ArtsyAPI.PlaceABid(auctionID: saleArtwork.auctionID!, artworkID: saleArtwork.artwork.id, maxBidCents: bidAmountCents)

        let request = provider().request(bidEndpoint, method: .POST, parameters:bidEndpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(BidderPosition.self)

        return request.doNext { [weak self] (position) -> Void in
            self?.bidderPosition = position as? BidderPosition
            return

        }.doError { (error) in
            log.error("Bidding on Sale Artwork failed.")
            log.error("Error: \(error.localizedDescription). \n \(error.artsyServerError())")
        }
    }

}
