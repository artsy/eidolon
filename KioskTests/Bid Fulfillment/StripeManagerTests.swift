import Quick
import Nimble
import RxSwift
@testable
import Kiosk
import Stripe

class StripeManagerTests: QuickSpec {
    override func spec() {
        var subject: StripeManager!
        var testStripeClient: TestSTPAPIClient!
        var disposeBag: DisposeBag!

        beforeEach {
            Stripe.setDefaultPublishableKey("some key")

            subject = StripeManager()
            testStripeClient = TestSTPAPIClient()
            subject.stripeClient = testStripeClient
            disposeBag = DisposeBag()
        }

        afterEach {
            Stripe.setDefaultPublishableKey("")
        }

        it("sends the correct token upon success") {
            waitUntil { done in
                subject.registerCard(digits: "", month: 0, year: 0, securityCode: "", postalCode: "").subscribe(onNext: { (object) in
                    let token = object

                    expect(token.tokenId) == "12345"
                    done()
                }).disposed(by: disposeBag)
            }
        }

        it("sends the correct token upon success") {
            var completed = false
            waitUntil { done in
                subject.registerCard(digits: "", month: 0, year: 0, securityCode: "", postalCode: "").subscribe(onCompleted: {
                    completed = true
                    done()
                }).disposed(by: disposeBag)
            }

            expect(completed) == true
        }

        it("sends error upon success") {
            testStripeClient.succeed = false
            
            var errored = false
            waitUntil { done in
                subject.registerCard(digits: "", month: 0, year: 0, securityCode: "", postalCode: "").subscribe(onError: { _ in
                    errored = true
                    done()
                }).disposed(by: disposeBag)
            }

            expect(errored) == true
        }
    }
}

class TestSTPAPIClient: Clientable {
    var succeed = true
    var token = TestToken()

    func kiosk_createToken(withCard card: STPCardParams, completion: ((Tokenable?, Error?) -> Void)?) {
        if succeed {
            completion?(token, nil)
        } else {
            completion?(nil, TestError.Default)
        }
    }
}
