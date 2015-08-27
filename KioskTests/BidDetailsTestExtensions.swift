import Foundation
@testable
import Kiosk

extension BidDetails {

    class func stubbedBidDetails() -> BidDetails {

        return BidDetails(saleArtwork: testSaleArtwork(), paddleNumber: "1111", bidderPIN: "2222", bidAmountCents: 123456)
    }

}