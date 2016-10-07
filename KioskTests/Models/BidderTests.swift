import Quick
import Nimble
@testable
import Kiosk

class BidderTests: QuickSpec {
    override func spec() {

        it("converts from JSON") {
            let id = "324ddf445"
            let saleID = "asdkhaskda"
            let data:[String: Any] =  ["id":id , "sale" : ["id": saleID]]

            let bidder = Bidder.fromJSON(data)

            expect(bidder.id) == id
            expect(bidder.saleID) == saleID
        }

    }
}
