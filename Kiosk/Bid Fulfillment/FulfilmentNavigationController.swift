import UIKit

class FulfillmentNavigationController: UINavigationController {
    var bidDetails = BidDetails(saleArtwork:nil, bidderID: nil, bidderPIN: nil, bidAmountCents:nil)
    lazy var auctionID:String? = self.bidDetails.saleArtwork?.auctionID
}
