import Quick
import Nimble
import ReactiveCocoa
import Swift_RAC_Macros
@testable
import Kiosk
import Stripe

class ManualCreditCardInputViewModelTests: QuickSpec {
    override func spec() {
        var testStripeManager: ManualCreditCardInputViewModelTestsStripeManager!
        var bidDetails: BidDetails!
        var subject: ManualCreditCardInputViewModel!

        beforeEach{ () -> () in
            Stripe.setDefaultPublishableKey("some key")

            bidDetails = testBidDetails()
            testStripeManager = ManualCreditCardInputViewModelTestsStripeManager()

            subject = ManualCreditCardInputViewModel(bidDetails: bidDetails, finishedSubject: RACSubject())
            subject.stripeManager = testStripeManager
        }

        afterEach {
            Stripe.setDefaultPublishableKey(nil)
        }
        
        it("initializer assigns bid details") { () -> () in
            expect(subject.bidDetails) == bidDetails
        }

        it("initializer assigns credit card details to empty strings") {
            expect(subject.cardFullDigits) == ""
            expect(subject.expirationMonth) == ""
            expect(subject.expirationYear) == ""
        }

        it("has valid credit card when credit card is valid") { () -> () in
            testStripeManager.isValidCreditCard = true
            expect((subject.creditCardNumberIsValidSignal.first() as! Bool)) == true
        }

        it("has invalid credit card when credit card is invalid") { () -> () in
            testStripeManager.isValidCreditCard = false
            expect((subject.creditCardNumberIsValidSignal.first() as! Bool)) == false
        }

        it("moves to year when month reaches two digits") {
            var moved = false

            subject.moveToYearSignal.subscribeNext { _ -> Void in
                moved = true
            }

            subject.expirationMonth = "12"

            expect(moved) == true
        }

        it("doesn't move to year when month reaches one digit") {
            var moved = false

            subject.moveToYearSignal.subscribeNext { _ -> Void in
                moved = true
            }

            subject.expirationMonth = "2"

            expect(moved) == false
        }

        describe("expiry date") { () -> () in
            describe("with a valid year") { () -> Void in
                beforeEach {
                    subject.expirationYear = "2022"
                }

                it("is valid when month is two digits") {
                    subject.expirationMonth = "12"
                    expect((subject.expiryDatesAreValidSignal.first() as! Bool)) == true
                }

                it("is valid when month is one digit") {
                    subject.expirationMonth = "1"
                    expect((subject.expiryDatesAreValidSignal.first() as! Bool)) == true
                }

                it("is invalid when month is no digits") {
                    subject.expirationMonth = ""
                    expect((subject.expiryDatesAreValidSignal.first() as! Bool)) == false
                }
            }

            describe("with a valid month") {
                beforeEach {
                    subject.expirationMonth = "12"
                }

                it("is valid when year is two digits") {
                    subject.expirationYear = "22"
                    expect((subject.expiryDatesAreValidSignal.first() as! Bool)) == true
                }

                it("is valid when year is four digits") {
                    subject.expirationYear = "2022"
                    expect((subject.expiryDatesAreValidSignal.first() as! Bool)) == true
                }

                it("is invalid when year is one digit") {
                    subject.expirationYear = "2"
                    expect((subject.expiryDatesAreValidSignal.first() as! Bool)) == false
                }

                it("is invalid when year is no digits") {
                    subject.expirationYear = ""
                    expect((subject.expiryDatesAreValidSignal.first() as! Bool)) == false
                }

                it("is invalid when year is five digits") {
                    subject.expirationYear = "22022"
                    expect((subject.expiryDatesAreValidSignal.first() as! Bool)) == false
                }
            }
        }

        describe("credit card registration") { () -> () in
            it("enables command with a valid credit card and valid expiry dates") {
                testStripeManager.isValidCreditCard = true
                subject.cardFullDigits = ""
                subject.expirationMonth = "02"
                subject.expirationYear = "2017"
                subject.securityCode = "123"
                expect((subject.registerButtonCommand().enabled.first() as! Bool)) == true
            }

            it("disables command with invalid credit card") {
                testStripeManager.isValidCreditCard = false
                subject.cardFullDigits = ""
                subject.expirationMonth = "02"
                subject.expirationYear = "2017"
                expect((subject.registerButtonCommand().enabled.first() as! Bool)) == false
            }

            it("disables command with invalid expiry date") {
                testStripeManager.isValidCreditCard = false
                subject.cardFullDigits = ""
                subject.expirationMonth = "02"
                subject.expirationYear = "207"
                expect((subject.registerButtonCommand().enabled.first() as! Bool)) == false
            }

            describe("a valid card and expiry date") {
                beforeEach {
                    testStripeManager.isValidCreditCard = true
                    subject.cardFullDigits = ""
                    subject.expirationMonth = "02"
                    subject.expirationYear = "2017"
                    subject.securityCode = "123"
                }

                describe("successful registration") { () -> Void in
                    it("registers with stripe") {
                        var registered = false
                        testStripeManager.registrationClosure = {
                            registered = true
                        }

                        subject.registerButtonCommand().execute(nil)

                        expect(registered).toEventually( beTrue() )
                    }

                    it("sets user state after successful registration") {
                        testStripeManager.token = STPToken(attributeDictionary: [
                            "id": "12345",
                            "card": [
                                "brand": "American Express",
                                "name": "Simon Suyez",
                                "last4": "0001"
                            ]
                            ])

                        subject.registerButtonCommand().execute(nil)

                        expect(subject.bidDetails.newUser.creditCardName).toEventually( equal("Simon Suyez") )
                        expect(subject.bidDetails.newUser.creditCardType).toEventually( equal("American Express") )
                        expect(subject.bidDetails.newUser.creditCardToken).toEventually( equal("12345") )
                        expect(subject.bidDetails.newUser.creditCardDigit).toEventually( equal("0001") )
                    }


                    it("sends completed to finishedSubject after reigsterButtonCommand successfully executes") {
                        var finished = false

                        subject.finishedSubject?.subscribeCompleted { () -> Void in
                            finished = true
                        }

                        waitUntil { (done) -> Void in
                            subject.registerButtonCommand().execute(nil).subscribeCompleted { () -> Void in
                                done()
                            }

                            return
                        }

                        expect(finished) == true
                    }
                }

                describe("unsuccessful registration") { () -> Void in
                    beforeEach { () -> () in
                        testStripeManager.shouldSucceed = false
                    }


                    it("does not send completed to finishedSubject after reigsterButtonCommand errors") {
                        var finished = false

                        subject.finishedSubject?.subscribeCompleted { () -> Void in
                            finished = true
                        }

                        waitUntil { (done) -> Void in
                            let command = subject.registerButtonCommand()
                            command.errors.subscribeNext{ _ -> Void in
                                done()
                            }

                            command.execute(nil)
                        }

                        expect(finished) == false
                    }
                }
            }
        }

        it("accepts empty entry strings") {
            expect(subject.isEntryValid("")) == true
        }

        it("accepts digit entry strings") {
            expect(subject.isEntryValid("1")) == true
        }

        it("rejects non-digit entry strings") {
            expect(subject.isEntryValid("a")) == false
        }
    }
}

class ManualCreditCardInputViewModelTestsStripeManager: StripeManager {
    var isValidCreditCard = false

    var registrationClosure: (() -> ())?
    var token: STPToken?
    var shouldSucceed = true

    override func stringIsCreditCard(object: AnyObject!) -> AnyObject! {
        return isValidCreditCard
    }

    override func registerCard(digits: String, month: UInt, year: UInt, securityCode: String, postalCode: String) -> RACSignal {
        return RACSignal.createSignal { (subscriber) -> RACDisposable! in
            self.registrationClosure?()

            if self.shouldSucceed {
                if let token = self.token {
                    subscriber.sendNext(token)
                }

                subscriber.sendCompleted()
            } else {
                subscriber.sendError(nil)
            }

            return nil
        }
    }
}
