import Quick
import Nimble
import ReactiveCocoa
import Swift_RAC_Macros
@testable
import Kiosk
import Stripe


class StripeManagerTests: QuickSpec {
    override func spec() {
        var subject: StripeManager!
        var testStripeClient: TestSTPAPIClient!

        beforeEach {
            Stripe.setDefaultPublishableKey("some key")

            subject = StripeManager()
            testStripeClient = TestSTPAPIClient()
            subject.stripeClient = testStripeClient
        }

        afterEach {
            Stripe.setDefaultPublishableKey(nil)
        }

        it("sends the correct token upon success") {
            waitUntil { (done) -> Void in
                subject.registerCard("", month: 0, year: 0, securityCode: "").subscribeNext { (object) -> Void in
                    let token = object as! STPToken

                    expect(token.tokenId) == "12345"
                    done()
                }
                return
            }
        }

        it("sends the correct token upon success") {
            var completed = false
            waitUntil { (done) -> Void in
                subject.registerCard("", month: 0, year: 0, securityCode: "").subscribeCompleted { () -> Void in
                    completed = true
                    done()
                }
                return
            }

            expect(completed) == true
        }

        it("sends error upon success") {
            testStripeClient.succeed = false
            
            var errored = false
            waitUntil { (done) -> Void in
                subject.registerCard("", month: 0, year: 0, securityCode: "").subscribeError { _ -> Void in
                    errored = true
                    done()
                }
                return
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
            completion(nil, nil)
        }
    }
}
