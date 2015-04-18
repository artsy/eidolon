import Quick
import Nimble
import Kiosk
import ReactiveCocoa
import Nimble_Snapshots
import Moya

class RegistrationPasswordViewControllerTests: QuickSpec {

    func testSubject(emailExists: Bool = false) -> RegistrationPasswordViewController {

        class TestViewModel: RegistrationPasswordViewModel {
            init (emailExists: Bool = false) {
                super.init(passwordSignal: RACSignal.empty(), manualInvocationSignal: RACSignal.empty(), finishedSubject: RACSubject(), email: "")

                emailExistsSignal = RACSignal.`return`(emailExists).replay()
            }
        }

        let subject = RegistrationPasswordViewController.instantiateFromStoryboard(fulfillmentStoryboard)
        subject.bidDetails = BidDetails.stubbedBidDetails()
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
    }
}
