import Quick
import Nimble
import Kiosk

class BidderTests: QuickSpec {
    override func spec() {

        it("converts from JSON") {
            let id = "324ddf445"
            let saleID = "asdkhaskda"
            let data:[String: AnyObject] =  ["id":id , "sale" : ["id": saleID]]

            let bidder = Bidder.fromJSON(data) as! Bidder

            expect(bidder.id) == id
            expect(bidder.saleID) == saleID
        }

    }
}
