import Quick
import Nimble
import Kiosk

class BidderPositionTests: QuickSpec {
    override func spec() {

        it("converts from JSON") {
            let id = "saf32sadasd"
            let maxBidAmountCents = 123123123

            let bidID = "saf32sadasd"
            let bidAmount = 100000
            let bidData:[String: AnyObject] = ["id": bidID, "amount_cents" : bidAmount ]

            let data:[String: AnyObject] =  ["id":id , "max_bid_amount_cents" : maxBidAmountCents, "highest_bid":bidData]

            let position = BidderPosition.fromJSON(data) as! BidderPosition

            expect(position.id) == id
            expect(position.maxBidAmountCents) == maxBidAmountCents
            expect(position.highestBid!.id) == bidID
            expect(position.highestBid!.amountCents) == bidAmount
        }

    }
}
