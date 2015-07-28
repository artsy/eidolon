import UIKit
import ReactiveCocoa
import Moya

public class PlaceBidNetworkModel: NSObject {

    public var fulfillmentController: FulfillmentController!
    public var bidderPosition: BidderPosition?

    public init(fulfillmentController: FulfillmentController) {
        self.fulfillmentController = fulfillmentController

        super.init()
    }

    public func bidSignal(bidDetails: BidDetails) -> RACSignal {

        let saleArtwork = bidDetails.saleArtwork
        let cents = String(bidDetails.bidAmountCents! as Int)
        return bidOnSaleArtwork(saleArtwork!, bidAmountCents: cents)
    }


    private func bidOnSaleArtwork(saleArtwork: SaleArtwork, bidAmountCents: String) -> RACSignal {
        let bidEndpoint: ArtsyAPI = ArtsyAPI.PlaceABid(auctionID: saleArtwork.auctionID!, artworkID: saleArtwork.artwork.id, maxBidCents: bidAmountCents)

        let request = fulfillmentController.loggedInProvider!.request(bidEndpoint).filterSuccessfulStatusCodes().mapJSON().mapToObject(BidderPosition.self)

        return request.doNext { [weak self] (position) -> Void in
            self?.bidderPosition = position as? BidderPosition
            return

        }.doError { (error) in
            logger.log("Bidding on Sale Artwork failed.")
            logger.log("Error: \(error.localizedDescription). \n \(error.artsyServerError())")
        }
    }

}
