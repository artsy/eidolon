import Quick
import Nimble
@testable
import Kiosk
import RxSwift
import Nimble_Snapshots
import Action
import Moya

class RegistrationPasswordViewControllerTests: QuickSpec {

    func testSubject(emailExists: Bool = false) -> RegistrationPasswordViewController {

        class TestViewModel: RegistrationPasswordViewModelType {

            var emailExists: Observable<Bool>
            var action: CocoaAction! = emptyAction()

            init (emailExists: Bool = false) {
                self.emailExists = Observable.just(emailExists)
            }

            func userForgotPassword() -> Observable<Void> {
                return Observable.empty()
            }
        }

        let subject = RegistrationPasswordViewController.instantiateFromStoryboard(fulfillmentStoryboard)
        subject.bidDetails = testBidDetails()
        subject.viewModel = TestViewModel(emailExists: emailExists)
        return subject
    }

    override func spec() {
        it("looks right by default") {
            let subject = self.testSubject()
            expect(subject).to( haveValidSnapshot() )
        }

        it("looks right with an existing email") {
            let subject = self.testSubject(emailExists: true)
            expect(subject).to( haveValidSnapshot() )
        }

        it("looks right with a valid password") {
            let subject = self.testSubject()
            subject.loadViewProgrammatically()
            subject.passwordTextField.text = "password"
            expect(subject).to( haveValidSnapshot() )
        }

        it("looks right with an invalid password") {
            let subject = self.testSubject()
            subject.loadViewProgrammatically()
            subject.passwordTextField.text = "short"
            expect(subject).to( haveValidSnapshot() )
        }

        it("unbinds bidDetails on viewWillDisappear:") {
            let runLifecycleOfViewController = { (bidDetails: BidDetails) -> RegistrationPasswordViewController in
                let subject = RegistrationPasswordViewController.instantiateFromStoryboard(fulfillmentStoryboard)
                subject.provider = Networking.newStubbingNetworking()
                subject.bidDetails = bidDetails
                subject.loadViewProgrammatically()
                subject.viewWillDisappear(false)
                return subject
            }

            let bidDetails = testBidDetails()
            _ = runLifecycleOfViewController(bidDetails)

            expect { runLifecycleOfViewController(bidDetails) }.toNot( raiseException() )
        }
    }
}
