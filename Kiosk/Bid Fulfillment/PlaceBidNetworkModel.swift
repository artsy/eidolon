import Foundation
import RxSwift
import Moya
import SwiftyJSON

let OutbidDomain = "Outbid"

protocol PlaceBidNetworkModelType {
    var bidDetails: BidDetails { get }

    func bid(provider: AuthorizedNetworking) -> Observable<String>
}

class PlaceBidNetworkModel: NSObject, PlaceBidNetworkModelType {

    let bidDetails: BidDetails

    init(bidDetails: BidDetails) {
        self.bidDetails = bidDetails

        super.init()
    }

    func bid(provider: AuthorizedNetworking) -> Observable<String> {
        let saleArtwork = bidDetails.saleArtwork.value

        assert(saleArtwork.hasValue, "Sale artwork cannot nil at bidding stage.")

        let cents = (bidDetails.bidAmountCents.value as? Int) ?? 0
        return bidOnSaleArtwork(saleArtwork!, bidAmountCents: String(cents), provider: provider)
    }

    private func bidOnSaleArtwork(saleArtwork: SaleArtwork, bidAmountCents: String, provider: AuthorizedNetworking) -> Observable<String> {
        let bidEndpoint = ArtsyAuthenticatedAPI.PlaceABid(auctionID: saleArtwork.auctionID!, artworkID: saleArtwork.artwork.id, maxBidCents: bidAmountCents)

        let request = provider
            .request(bidEndpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObject(BidderPosition)

        return request
            .map { position in
                return position.id
            }.catchError { e -> Observable<String> in
                // We've received an error. We're going to check to see if it's type is "param_error", which indicates we were outbid.

                guard let error = e as? Moya.Error else { throw e }
                guard case .StatusCode(let response) = error else { throw e }


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
