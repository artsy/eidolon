import Quick
import Nimble
import ReactiveCocoa
//import
 Moya
@testable
import Kiosk

class BidderNetworkModelTests: QuickSpec {
    override func spec() {
        var fulfillmentController: StubFulfillmentController!
        var subject: BidderNetworkModel!

        beforeEach {
            fulfillmentController = StubFulfillmentController()
            subject = BidderNetworkModel(fulfillmentController: fulfillmentController)
        }

        it("matches hasBeenRegistered is false") {
            expect(subject.createdNewUser.first() as? Bool) == false
        }

        it("matches hasBeenRegistered is true") {
            fulfillmentController.bidDetails.newUser.hasBeenRegistered = true
            expect(subject.createdNewUser.first() as? Bool) == true
        }
    }
}