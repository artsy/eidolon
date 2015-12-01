import Foundation
import RxSwift
import Moya
import SwiftyJSON

let OutbidDomain = "Outbid"

protocol PlaceBidNetworkModelType {
    var fulfillmentController: FulfillmentController { get }

    func bidSignal() -> Observable<String>
}

class PlaceBidNetworkModel: NSObject, PlaceBidNetworkModelType {

    unowned let fulfillmentController: FulfillmentController
    var bidderPosition: BidderPosition?

    var provider: RxMoyaProvider<ArtsyAPI>! {
        return self.fulfillmentController.loggedInProvider
    }

    init(fulfillmentController: FulfillmentController) {
        self.fulfillmentController = fulfillmentController

        super.init()
    }

    func bidSignal() -> Observable<String> {
        let bidDetails = fulfillmentController.bidDetails
        let saleArtwork = bidDetails.saleArtwork.value

        assert(saleArtwork.hasValue, "Sale artwork is nil at bidding stage.")

        let cents = (bidDetails.bidAmountCents.value as? Int) ?? 0
        return bidOnSaleArtwork(saleArtwork!, bidAmountCents: String(cents))
    }

    private func bidOnSaleArtwork(saleArtwork: SaleArtwork, bidAmountCents: String) -> Observable<String> {
        let bidEndpoint: ArtsyAPI = ArtsyAPI.PlaceABid(auctionID: saleArtwork.auctionID!, artworkID: saleArtwork.artwork.id, maxBidCents: bidAmountCents)

        let request = provider
            .request(bidEndpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObject(BidderPosition)

        return request
            .map { [weak self] position in
                self?.bidderPosition = position
                return position.id
            }.catchError { error -> Observable<String> in
                // We've received an error. We're going to check to see if it's type is "param_error", which indicates we were outbid.

                guard let data: AnyObject = (error as NSError).userInfo["data"] else {
                    throw error
                }

                if let type = JSON(data)["type"].string where type == "param_error" {
                    throw NSError(domain: OutbidDomain, code: 0, userInfo: [NSUnderlyingErrorKey: error as NSError])
                } else {
                    throw error
                }
            }
            .logError()
    }

}
