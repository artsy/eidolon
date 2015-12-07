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
            Stripe.setDefaultPublishableKey(nil)
        }

        it("sends the correct token upon success") {
            waitUntil { done in
                subject.registerCard("", month: 0, year: 0, securityCode: "", postalCode: "").subscribeNext { (object) in
                    let token = object

                    expect(token.tokenId) == "12345"
                    done()
                }.addDisposableTo(disposeBag)
            }
        }

        it("sends the correct token upon success") {
            var completed = false
            waitUntil { done in
                subject.registerCard("", month: 0, year: 0, securityCode: "", postalCode: "").subscribeCompleted {
                    completed = true
                    done()
                }.addDisposableTo(disposeBag)
            }

            expect(completed) == true
        }

        it("sends error upon success") {
            testStripeClient.succeed = false
            
            var errored = false
            waitUntil { done in
                subject.registerCard("", month: 0, year: 0, securityCode: "", postalCode: "").subscribeError { _ in
                    errored = true
                    done()
                }.addDisposableTo(disposeBag)
            }

            expect(errored) == true
        }
    }
}

class TestSTPAPIClient: STPAPIClient {
    var succeed = true
    var token = STPToken(attributeDictionary: [
        "id": "12345",
        "card": [
            "brand": "American Express",
            "name": "Simon Suyez",
            "last4": "0001"
        ]
    ])

    override func createTokenWithCard(card: STPCard!, completion: STPCompletionBlock!) {
        if succeed {
            completion(token, nil)
        } else {
            completion(nil, TestError.Default as NSError)
        }
    }
}
