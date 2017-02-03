import Quick
import Nimble
@testable
import Kiosk

class BidderPositionTests: QuickSpec {
    override func spec() {

        it("converts from JSON") {
            let id = "saf32sadasd"
            let maxBidAmountCents: Currency = 123123123

            let bidID = "saf32sadasd"
            let bidAmount: Currency = 100000
            let bidData:[String: Any] = ["id": bidID as AnyObject, "amount_cents" : bidAmount ]

            let data:[String: Any] =  ["id":id as AnyObject , "max_bid_amount_cents" : maxBidAmountCents, "highest_bid":bidData]

            let position = BidderPosition.fromJSON(data)

            expect(position.id) == id
            expect(position.maxBidAmountCents) == maxBidAmountCents
            expect(position.highestBid!.id) == bidID
            expect(position.highestBid!.amountCents) == bidAmount
        }

    }
}
