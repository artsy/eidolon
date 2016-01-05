import Quick
import Nimble
import RxSwift
import Moya
@testable
import Kiosk

class BidderNetworkModelTests: QuickSpec {
    override func spec() {
        var bidDetails: BidDetails!
        var subject: BidderNetworkModel!

        beforeEach {
            bidDetails = testBidDetails()
            subject = BidderNetworkModel(provider: Networking.newStubbingNetworking(), bidDetails: bidDetails)
        }

        it("matches hasBeenRegistered is false") {
            expect(subject.createdNewUser) == false
        }

        it("matches hasBeenRegistered is true") {
            bidDetails.newUser.hasBeenRegistered.value = true
            expect(try! subject.createdNewUser.toBlocking().first()) == true
        }
    }
}