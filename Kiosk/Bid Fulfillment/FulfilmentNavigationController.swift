import UIKit

class FulfillmentNavigationController: UINavigationController {
    var bidDetails = BidDetails(saleArtwork:nil, bidderID: nil, bidderPIN: nil, bidAmountCents:nil)

    var networkProvider:ReactiveMoyaProvider<ArtsyAPI> = ReactiveMoyaProvider(endpointsClosure: endpointsClosure, stubResponses: false)
}
