import Quick
import Nimble
@testable
import Kiosk

class BidTests: QuickSpec {
    override func spec() {
        it("converts from JSON") {
            let id = "saf32sadasd"
            let amount: Currency = 100000
            let data:[String: Any] =  ["id":id as AnyObject , "amount_cents" : amount ]

            let bid = Bid.fromJSON(data)

            expect(bid.id) == id
            expect(bid.amountCents) == amount
        }
    }
}
