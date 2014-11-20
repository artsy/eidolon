import Quick
import Nimble
import Kiosk
import ISO8601DateFormatter

class SaleTests: QuickSpec {
    func stringFromDate(date: NSDate) -> String {
        return ISO8601DateFormatter().stringFromDate(date)
    }

    override func spec() {

        it("converts from JSON") {
            let id = "saf32sadasd"
            let isAuction = true
            let startDate = "2014-09-21T19:22:24Z"
            let endDate = "2015-09-24T19:22:24Z"
            let name = "name"
            let data:[String: AnyObject] =  ["id":id , "is_auction" : isAuction, "name": name, "start_at":startDate, "end_at":endDate]

            let sale = Sale.fromJSON(data) as Sale

            expect(sale.id) == id
            expect(sale.isAuction) == isAuction
            expect(yearFromDate(sale.startDate)) == 2014
            expect(yearFromDate(sale.endDate)) == 2015
            expect(sale.name) == name
        }
        
        describe("active state") {
            it("is inactive for past auction") {
                let artsyTime = SystemTime()
                artsyTime.systemTimeInterval = 0

                let date = NSDate.distantPast() as NSDate
                let dateString = self.stringFromDate(date)

                let data:[String: AnyObject] =  ["start_at": dateString, "end_at" : dateString]

                let sale = Sale.fromJSON(data) as Sale
                expect(sale.isActive(artsyTime)) == false
            }

            it("is active for current auction") {
                let artsyTime = SystemTime()
                artsyTime.systemTimeInterval = 0

                let pastDate = NSDate.distantPast() as NSDate
                let pastString = self.stringFromDate(pastDate)

                let futureDate = NSDate.distantFuture() as NSDate
                let futureString = self.stringFromDate(futureDate)

                let data:[String: AnyObject] =  ["start_at": pastString, "end_at" : futureString]

                let sale = Sale.fromJSON(data) as Sale

                expect(sale.isActive(artsyTime)) == true
            }

            it("is inactive for future auction") {
                let artsyTime = SystemTime()
                artsyTime.systemTimeInterval = 0

                let date = NSDate.distantFuture() as NSDate
                let dateString = self.stringFromDate(date)

                let data:[String: AnyObject] =  ["start_at": dateString, "end_at" : dateString]

                let sale = Sale.fromJSON(data) as Sale
                expect(sale.isActive(artsyTime)) == false
            }
        }
    }
}