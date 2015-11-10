import Quick
import Nimble
import RxSwift
@testable
import Kiosk

class RAC_JSONAbleTests: QuickSpec {
    override func spec() {

        let id = "324ddf445"
        let saleID = "asdkhaskda"
        let data:[String: AnyObject] =  ["id":id , "sale" : ["id": saleID]]

        it("converts JSON to a JSONAble"){

            let dataSubject = RACSubject()
            let objectSignal = dataSubject.mapToObject(Bidder.self)

            var success = false
            objectSignal.subscribeNext({ (object) -> Void in
                let bidder = object as! Bidder
                success = (bidder.id == id)
            })

            dataSubject.sendNext(data)
            expect(success) == true
        }

        it("converts a JSON array to many JSONAbles"){

            let dataSubject = RACSubject()
            let objectSignal = dataSubject.mapToObjectArray(Bidder.self)

            var success = false
            objectSignal.subscribeNext({ (object) -> Void in
                let bidder = object as! [Bidder]
                success = (bidder.count == 2)
            })

            dataSubject.sendNext([data, data])
            expect(success) == true
        }

    }
}
