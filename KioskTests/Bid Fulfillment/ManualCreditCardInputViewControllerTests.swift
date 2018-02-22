import Quick
import Nimble
@testable
import Kiosk
import RxSwift
import Nimble_Snapshots
import Action

class ManualCreditCardInputViewControllerTests: QuickSpec {
    override func spec() {
        var subject: ManualCreditCardInputViewController!
        var testViewModel: ManualCreditCardInputTestViewModel!
        var disposeBag: DisposeBag!

        beforeEach {
            testViewModel = ManualCreditCardInputTestViewModel(bidDetails: testBidDetails())
            subject = ManualCreditCardInputViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.viewModel = testViewModel
            disposeBag = DisposeBag()
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
            _ = runLifecycleOfViewController(bidDetails)

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
                testViewModel.testRegisterButtonCommand = disabledAction()

                subject.loadViewProgrammatically()
                subject.cardNumberconfirmTapped(subject)
            }
        }

        describe("after CC is entered with valid dates") {
            var executed: Bool!

            beforeEach {
                executed = false
                testViewModel.testRegisterButtonCommand = CocoaAction { _ in
                    executed = true
                    return Observable.empty()
                }

                subject.loadViewProgrammatically()
                subject.cardNumberconfirmTapped(subject)
            }

            it("uses registerButtonCommand enabledness for date button") {
                expect(subject).to( haveValidSnapshot() )
            }

            it("invokes registerButtonCommand on press") {
                waitUntil { done in
                    testViewModel
                        .testRegisterButtonCommand
                        .execute(Void())
                        .subscribe(onCompleted: {
                            expect(executed) == true
                            done()
                        })
                        .disposed(by: disposeBag)
                    
                    return
                }
            }
        }

        it("shows errors") {
            testViewModel.testRegisterButtonCommand = errorAction()

            subject.loadViewProgrammatically()
            subject.cardNumberconfirmTapped(subject)
            subject.expirationDateConfirmTapped(subject)

            waitUntil { done in
                testViewModel
                    .testRegisterButtonCommand
                    .execute(Void())
                    .subscribe(onError: { (_) in
                        done()
                    })
                    .disposed(by: disposeBag)
            }

            expect(subject).to( haveValidSnapshot() )
        }
    }
}

class ManualCreditCardInputTestViewModel: ManualCreditCardInputViewModel {
    var CCIsValid = false
    var moveToYearSubject = PublishSubject<Void>()
    var testRegisterButtonCommand = CocoaAction(enabledIf: Observable.just(false)) { _ in Observable.empty() }

    override var creditCardNumberIsValid: Observable<Bool> {
        return Observable.just(CCIsValid)
    }

    override var moveToYear: Observable<Void> {
        return moveToYearSubject.asObservable()
    }

    override func registerButtonCommand() -> CocoaAction {
        return testRegisterButtonCommand
    }
}
