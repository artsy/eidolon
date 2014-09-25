import Foundation

final class BidPosition: NSObject, JSONAble {
    let id:String
    let highestBid:Bid
    let maxBidAmountCents:Int

    init(id: String, highestBid:Bid, maxBidAmountCents:Int) {
        self.id = id
        self.highestBid = highestBid
        self.maxBidAmountCents = maxBidAmountCents
    }

    class func fromJSON(source:[String: AnyObject]) -> BidPosition {
        let json = JSON(object: source)

        let id = json["id"].stringValue
        let maxBidAmount = json["max_bid_amount_cents"].integerValue

        let bidDictionary = json["highest_bid"].object as [String: AnyObject]
        let bid = Bid.fromJSON(bidDictionary)

        return BidPosition(id: id, highestBid: bid, maxBidAmountCents: maxBidAmount)
    }
}
