import Foundation
import RxSwift
import Moya
import SwiftyJSON

let OutbidDomain = "Outbid"

class PlaceBidNetworkModel: NSObject {

    unowned let fulfillmentController: FulfillmentController
    var bidderPosition: BidderPosition?

    var provider: ReactiveCocoaMoyaProvider<ArtsyAPI>! {
        return self.fulfillmentController.loggedInProvider
    }

    init(fulfillmentController: FulfillmentController) {
        self.fulfillmentController = fulfillmentController

        super.init()
    }

    func bidSignal() -> Observable<String> {
        let bidDetails = fulfillmentController.bidDetails

        let saleArtwork = bidDetails.saleArtwork
        let cents = String(bidDetails.bidAmountCents! as Int)
        return bidOnSaleArtwork(saleArtwork!, bidAmountCents: cents)
    }

    private func bidOnSaleArtwork(saleArtwork: SaleArtwork, bidAmountCents: String) -> RACSignal {
        let bidEndpoint: ArtsyAPI = ArtsyAPI.PlaceABid(auctionID: saleArtwork.auctionID!, artworkID: saleArtwork.artwork.id, maxBidCents: bidAmountCents)

        let request = provider.request(bidEndpoint).filterSuccessfulStatusCodes().mapJSON().mapToObject(BidderPosition.self)

        return request.map { [weak self] position in
            self?.bidderPosition = position as? BidderPosition
            return position?.id
        }.`catch` { error -> RACSignal! in
            // We've received an error. We're going to check to see if it's type is "param_error", which indicates we were outbid.
            let data = error.userInfo["data"]

            return RACSignal.`return`(data).mapJSON().tryMap{ (object, errorPointer) -> AnyObject! in
                if let type = JSON(object)["type"].string where type == "param_error" {
                    errorPointer.memory = NSError(domain: OutbidDomain, code: 0, userInfo: [NSUnderlyingErrorKey: error])
                } else {
                    errorPointer.memory = error
                }

                // Return nil, causing this signal to error again. This time, it may have a new error, though.
                return nil
            }

        }.doError { (error) in
            logger.log("Bidding on Sale Artwork failed.")
            logger.log("Error: \(error.localizedDescription). \n \(error.artsyServerError())")
        }
    }

}
