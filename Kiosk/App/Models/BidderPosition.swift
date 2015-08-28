import Foundation
import SwiftyJSON

class BidderPosition: JSONAble {
    let id: String
    let highestBid:Bid?
    let maxBidAmountCents: Int

    init(id: String, highestBid:Bid?, maxBidAmountCents: Int) {
        self.id = id
        self.highestBid = highestBid
        self.maxBidAmountCents = maxBidAmountCents
    }

    override class func fromJSON(source:[String: AnyObject]) -> JSONAble {
        let json = JSON(source)

        let id = json["id"].stringValue
        let maxBidAmount = json["max_bid_amount_cents"].intValue

        var bid: Bid?
        if let bidDictionary = json["highest_bid"].object as? [String: AnyObject] {
            bid = Bid.fromJSON(bidDictionary) as? Bid
        }

        return BidderPosition(id: id, highestBid: bid, maxBidAmountCents: maxBidAmount)
    }
}
