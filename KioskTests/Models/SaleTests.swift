import Quick
import Nimble

class SaleTests: QuickSpec {
    override func spec() {

        it("converts from JSON") {
            let id = "saf32sadasd"
            let isAuction = true
            let startDate = "2014-09-21T19:22:24Z"
            let endDate = "2015-09-24T19:22:24Z"

            let data:[String: AnyObject] =  ["id":id , "is_auction" : isAuction, "start_at":startDate, "end_at":endDate]

            let sale = Sale.fromJSON(data)

            expect(sale.id) == id
            expect(sale.isAuction) == isAuction
            expect(yearFromDate(sale.startDate)) == 2014
            expect(yearFromDate(sale.endDate)) == 2015
        }
        
        describe("active state") {
            it("is inactive for past auction") {
                let artsyTime = SystemTime()
                artsyTime.systemTimeInterval = 0

                let sale = Sale(id: "", isAuction: true, startDate: NSDate.distantPast() as NSDate, endDate: NSDate.distantPast() as NSDate)

                expect(sale.isActive(artsyTime)) == false
            }

            it("is active for current auction") {
                let artsyTime = SystemTime()
                artsyTime.systemTimeInterval = 0

                let sale = Sale(id: "", isAuction: true, startDate: NSDate.distantPast() as NSDate, endDate: NSDate.distantFuture() as NSDate)

                expect(sale.isActive(artsyTime)) == true
            }

            it("is inactive for future auction") {
                let artsyTime = SystemTime()
                artsyTime.systemTimeInterval = 0

                let sale = Sale(id: "", isAuction: true, startDate: NSDate.distantFuture() as NSDate, endDate: NSDate.distantFuture() as NSDate)

                expect(sale.isActive(artsyTime)) == false

            }
        }
    }
}