import Quick
import Nimble

class BidTests: QuickSpec {
    override func spec() {
        it("converts from JSON") {
            let id = "saf32sadasd"
            let amount = 100000
            let data:[String: AnyObject] =  ["id":id , "amount_cents" : amount ]

            let bid = Bid.fromJSON(data)

            expect(bid.id) == id
            expect(bid.amountCents) == amount
        }
    }
}
