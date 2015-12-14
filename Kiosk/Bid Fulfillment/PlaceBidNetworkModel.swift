import Foundation
import RxSwift
import Moya
import SwiftyJSON

let OutbidDomain = "Outbid"

protocol PlaceBidNetworkModelType {
    var bidDetails: BidDetails { get }

    func bid() -> Observable<String>
}

class PlaceBidNetworkModel: NSObject, PlaceBidNetworkModelType {

    let provider: NetworkingType
    let bidDetails: BidDetails

    init(provider: NetworkingType, bidDetails: BidDetails) {
        self.provider = provider
        self.bidDetails = bidDetails

        super.init()
    }

    func bid() -> Observable<String> {
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
            .map { position in
                return position.id
            }.catchError { error -> Observable<String> in
                // We've received an error. We're going to check to see if it's type is "param_error", which indicates we were outbid.

                guard let response = (error as NSError).userInfo["data"] as? MoyaResponse else {
                    throw error
                }

                let json = JSON(data: response.data)

                if let type = json["type"].string where type == "param_error" {
                    throw NSError(domain: OutbidDomain, code: 0, userInfo: [NSUnderlyingErrorKey: error as NSError])
                } else {
                    throw error
                }
            }
            .logError()
    }

}
