import Quick
import Nimble
@testable
import Kiosk
import ReactiveCocoa
import Nimble_Snapshots

class ManualCreditCardInputViewControllerTests: QuickSpec {
    override func spec() {
        var subject: ManualCreditCardInputViewController!
        var testViewModel: ManualCreditCardInputTestViewModel!

        beforeEach {
            testViewModel = ManualCreditCardInputTestViewModel(bidDetails: testBidDetails())
            subject = ManualCreditCardInputViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.viewModel = testViewModel
        }

        it("unbinds bidDetails on viewWillDisappear:") {
            let runLifecycleOfViewController = { (bidDetails: BidDetails) -> ManualCreditCardInputViewController in
                let subject = ManualCreditCardInputViewController.instantiateFromStoryboard(fulfillmentStoryboard)
                subject.viewModel = ManualCreditCardInputTestViewModel(bidDetails: bidDetails)
                subject.loadViewProgrammatically()
                subject.viewWillDisappear(false)
                return subject
            }

            let bidDetails = testBidDetails()
            runLifecycleOfViewController(bidDetails)

            expect { runLifecycleOfViewController(bidDetails) }.toNot( raiseException() )
        }

        it("asks for CC number by default") {
            expect(subject).to( haveValidSnapshot() )
        }

        it("enables CC entry field when CC is valid") {
            testViewModel.CCIsValid = true
            expect(subject).to( haveValidSnapshot() )
        }

        describe("after CC is entered") {
            beforeEach {
                testViewModel.testRegisterButtonCommand = RACCommand(enabled: RACSignal.`return`(false)) { _ -> RACSignal! in
                    return RACSignal.empty()
                }

                subject.loadViewProgrammatically()
                subject.cardNumberconfirmTapped(subject)
            }

            it("moves cursor to year once month is entered") {
                var moved = false
                subject.expirationYearTextField?.rac_signalForSelector("becomeFirstResponder").subscribeNext { _ -> Void in
                    moved = true
                }
                testViewModel.moveToYearSubject.sendNext(nil)
                expect(moved).toEventually( beTrue() )
            }


            describe("date confirm button") {
            }
        }

        describe("after CC is entered with valid dates") {
            var executed: Bool!

            beforeEach {
                executed = false
                testViewModel.testRegisterButtonCommand = RACCommand(enabled: RACSignal.`return`(true)) { _ -> RACSignal! in
                    executed = true
                    return RACSignal.empty()
                }

                subject.loadViewProgrammatically()
                subject.cardNumberconfirmTapped(subject)
            }

            it("uses registerButtonCommand enabledness for date button") {
                expect(subject).to( haveValidSnapshot() )
            }

            it("invokes registerButtonCommand on press") {
                waitUntil { (done) -> Void in
                    testViewModel.testRegisterButtonCommand.execute(nil).subscribeCompleted { (_) -> Void in

                        expect(executed) == true
                        done()
                    }
                    
                    return
                }
            }
        }

        it("shows errors") {
            testViewModel.testRegisterButtonCommand = RACCommand(enabled: RACSignal.`return`(true)) { _ -> RACSignal! in
                return RACSignal.error(nil)
            }

            subject.loadViewProgrammatically()
            subject.cardNumberconfirmTapped(subject)
            subject.expirationDateConfirmTapped(subject)

            waitUntil { done -> Void in
                testViewModel.testRegisterButtonCommand.execute(nil).subscribeError { (_) -> Void in
                    done()
                }
            }

            expect(subject).to( haveValidSnapshot() )
        }
    }
}

class ManualCreditCardInputTestViewModel: ManualCreditCardInputViewModel {
    var CCIsValid = false
    var moveToYearSubject = RACSubject()
    var testRegisterButtonCommand: RACCommand

    override init(bidDetails: BidDetails!, finishedSubject: RACSubject? = nil) {
        testRegisterButtonCommand = RACCommand(enabled: RACSignal.`return`(false)) { (subscriber) -> RACSignal! in
            return RACSignal.empty()
        }

        super.init(bidDetails: bidDetails)
    }

    override var creditCardNumberIsValidSignal: RACSignal {
        return RACSignal.`return`(CCIsValid)
    }

    override var moveToYearSignal: RACSignal {
        return moveToYearSubject
    }

    override func registerButtonCommand() -> RACCommand {
        return testRegisterButtonCommand
    }
}
