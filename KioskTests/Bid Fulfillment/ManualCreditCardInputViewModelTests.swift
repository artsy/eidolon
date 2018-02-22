import Quick
import Nimble
import RxNimble
import RxOptional
import RxSwift
@testable
import Kiosk
import Stripe

class ManualCreditCardInputViewModelTests: QuickSpec {
    override func spec() {
        var testStripeManager: ManualCreditCardInputViewModelTestsStripeManager!
        var bidDetails: BidDetails!
        var subject: ManualCreditCardInputViewModel!
        var disposeBag: DisposeBag!

        beforeEach {
            Stripe.setDefaultPublishableKey("some key")

            bidDetails = testBidDetails()
            testStripeManager = ManualCreditCardInputViewModelTestsStripeManager()

            subject = ManualCreditCardInputViewModel(bidDetails: bidDetails, finishedSubject: PublishSubject<Void>())
            subject.stripeManager = testStripeManager

            disposeBag = DisposeBag()
        }

        afterEach {
            Stripe.setDefaultPublishableKey("")
        }
        
        it("initializer assigns bid details") {
            expect(subject.bidDetails) == bidDetails
        }

        it("initializer assigns credit card details to empty strings") {
            expect(subject.cardFullDigits.asObservable()).first == ""
            expect(subject.expirationMonth.asObservable()).first == ""
            expect(subject.expirationYear.asObservable()).first == ""
        }

        it("has valid credit card when credit card is valid") {
            testStripeManager.isValidCreditCard = true
            expect(subject.creditCardNumberIsValid).first == true
        }

        it("has invalid credit card when credit card is invalid") {
            testStripeManager.isValidCreditCard = false
            expect(subject.creditCardNumberIsValid).first == false
        }

        it("moves to year when month reaches two digits") {
            var moved = false

            subject.moveToYear
                .subscribe(onNext: { _ in
                    moved = true
                })
                .disposed(by: disposeBag)

            subject.expirationMonth.value = "12"

            expect(moved) == true
        }

        it("doesn't move to year when month reaches one digit") {
            var moved = false

            subject.moveToYear
                .subscribe(onNext: { _ in
                    moved = true
                })
                .disposed(by: disposeBag)


            subject.expirationMonth.value = "2"

            expect(moved) == false
        }

        describe("expiry date") {
            describe("with a valid year") {
                beforeEach {
                    subject.expirationYear.value = "2022"
                }

                it("is valid when month is two digits") {
                    subject.expirationMonth.value = "12"
                    expect(subject.expiryDatesAreValid).first == true
                }

                it("is valid when month is one digit") {
                    subject.expirationMonth.value = "1"
                    expect(subject.expiryDatesAreValid).first == true
                }

                it("is invalid when month is no digits") {
                    subject.expirationMonth.value = ""
                    expect(subject.expiryDatesAreValid).first == false
                }
            }

            describe("with a valid month") {
                beforeEach {
                    subject.expirationMonth.value = "12"
                }

                it("is valid when year is two digits") {
                    subject.expirationYear.value = "22"
                    expect(subject.expiryDatesAreValid).first == true
                }

                it("is valid when year is four digits") {
                    subject.expirationYear.value = "2022"
                    expect(subject.expiryDatesAreValid).first == true
                }

                it("is invalid when year is one digit") {
                    subject.expirationYear.value = "2"
                    expect(subject.expiryDatesAreValid).first == false
                }

                it("is invalid when year is no digits") {
                    subject.expirationYear.value = ""
                    expect(subject.expiryDatesAreValid).first == false
                }

                it("is invalid when year is five digits") {
                    subject.expirationYear.value = "22022"
                    expect(subject.expiryDatesAreValid).first == false
                }
            }
        }

        describe("credit card registration") {
            it("enables command with a valid credit card and valid expiry dates") {
                testStripeManager.isValidCreditCard = true
                subject.cardFullDigits.value = ""
                subject.expirationMonth.value = "02"
                subject.expirationYear.value = "2017"
                subject.securityCode.value = "123"
                subject.billingZip.value = "10003"
                expect(subject.registerButtonCommand().enabled).first == true
            }

            it("disables command with invalid credit card") {
                testStripeManager.isValidCreditCard = false
                subject.cardFullDigits.value = ""
                subject.expirationMonth.value = "02"
                subject.expirationYear.value = "2017"

                var enabled: Bool?
                waitUntil { done in
                    subject.registerButtonCommand()
                        .enabled
                        .subscribe(onNext: { enabledValue in
                            enabled = enabledValue
                            done()
                        })
                        .disposed(by: disposeBag)
                }

                expect(enabled) == false
            }

            it("disables command with invalid expiry date") {
                testStripeManager.isValidCreditCard = false
                subject.cardFullDigits.value = ""
                subject.expirationMonth.value = "02"
                subject.expirationYear.value = "207"
                expect(subject.registerButtonCommand().enabled).first == false
            }

            describe("a valid card and expiry date") {
                beforeEach {
                    testStripeManager.isValidCreditCard = true
                    subject.cardFullDigits.value = ""
                    subject.expirationMonth.value = "02"
                    subject.expirationYear.value = "2017"
                    subject.securityCode.value = "123"
                    subject.billingZip.value = "10001"
                }

                describe("successful registration") {
                    it("registers with stripe") {
                        var registered = false
                        testStripeManager.registrationClosure = {
                            registered = true
                        }

                        subject.registerButtonCommand().execute(Void())

                        expect(registered).toEventually( beTrue() )
                    }

                    it("sets user state after successful registration") {
                        testStripeManager.token = TestToken()

                        subject.registerButtonCommand().execute(Void())

                        let newUser = subject.bidDetails.newUser
                        expect(newUser.creditCardName.asObservable().filterNil()).first.toEventually( equal("Simon Suyez") )
                        expect(newUser.creditCardType.asObservable().filterNil()).first.toEventually( equal("American Express") )
                        expect(newUser.creditCardToken.asObservable().filterNil()).first.toEventually( equal("12345") )
                        expect(newUser.creditCardDigit.asObservable().filterNil()).first.toEventually( equal("0001") )
                    }


                    it("sends completed to finishedSubject after reigsterButtonCommand successfully executes") {
                        var finished = false

                        subject
                            .finishedSubject?
                            .subscribe(onCompleted: {
                                finished = true
                            })
                            .disposed(by: disposeBag)

                        waitUntil { done in
                            subject
                                .registerButtonCommand()
                                .execute(Void())
                                .subscribe(onCompleted: {
                                    done()
                                })
                                .disposed(by: disposeBag)

                            return
                        }

                        expect(finished) == true
                    }
                }

                describe("unsuccessful registration") {
                    beforeEach {
                        testStripeManager.shouldSucceed = false
                    }


                    it("does not send completed to finishedSubject after reigsterButtonCommand errors") {
                        var finished = false

                        subject
                            .finishedSubject?
                            .subscribe(onCompleted: {
                                finished = true
                            })
                            .disposed(by: disposeBag)

                        waitUntil { done in
                            let command = subject.registerButtonCommand()
                            command
                                .errors
                                .subscribe(onNext: { _ in
                                    done()
                                })
                                .disposed(by: disposeBag)

                            command.execute(Void())
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

struct TestCreditCard: CreditCard {
    var name: String?
    var brandName: String?
    var last4: String
}

class TestToken: Tokenable {
    var tokenId = "12345"
    var creditCard: CreditCard? {
        return TestCreditCard(name: "Simon Suyez", brandName: "American Express", last4: "0001")
    }
}

class ManualCreditCardInputViewModelTestsStripeManager: StripeManager {
    var isValidCreditCard = false

    var registrationClosure: (() -> ())?
    var token: Tokenable?
    var shouldSucceed = true

    override func stringIsCreditCard(_: String) -> Bool {
        return isValidCreditCard
    }

    override func registerCard(digits: String, month: UInt, year: UInt, securityCode: String, postalCode: String) -> Observable<Tokenable> {
        return Observable.create { observer in
            self.registrationClosure?()

            if self.shouldSucceed {
                if let token = self.token {
                    observer.onNext(token)
                }

                observer.onCompleted()
            } else {
                observer.onError(TestError.Default)
            }

            return Disposables.create()
        }
    }
}
