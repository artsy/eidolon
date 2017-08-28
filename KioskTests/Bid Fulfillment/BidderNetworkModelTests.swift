import Quick
import Nimble
import RxNimble
import RxSwift
import Moya
@testable
import Kiosk

class BidderNetworkModelTests: QuickSpec {
    override func spec() {
        var bidDetails: BidDetails!
        var subject: BidderNetworkModel!
        var disposeBag: DisposeBag!

        beforeEach {
            bidDetails = testBidDetails()
            bidDetails.newUser.email.value = "asdf@asdf.asdf"
            bidDetails.newUser.phoneNumber.value = "12345678"
            bidDetails.newUser.zipCode.value = "10013"
            subject = BidderNetworkModel(provider: Networking.newStubbingNetworking(), bidDetails: bidDetails)
            disposeBag = DisposeBag()
        }

        it("matches hasBeenRegistered is false") {
            expect(subject.createdNewUser) == false
        }

        it("matches hasBeenRegistered is true") {
            bidDetails.newUser.hasBeenRegistered.value = true
            expect(try! subject.createdNewUser.toBlocking().first()) == true
        }

        it("sends a value even if not adding a card") {
            waitUntil { done in
                subject
                    .createOrGetBidder()
                    .subscribe(onNext: { _ in
                        done()
                    })
                    .addDisposableTo(disposeBag)
            }
        }
    }
}
