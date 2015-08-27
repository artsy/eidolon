import Quick
import Nimble
@testable
import Kiosk
import Nimble_Snapshots

func testConfirmYourBidEnterYourEmailViewController() -> ConfirmYourBidEnterYourEmailViewController {
    return ConfirmYourBidEnterYourEmailViewController.instantiateFromStoryboard(fulfillmentStoryboard).wrapInFulfillmentNav() as! ConfirmYourBidEnterYourEmailViewController
}

class ConfirmYourBidEnterYourEmailViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let subject = testConfirmYourBidEnterYourEmailViewController()
            expect(subject).to(haveValidSnapshot())
        }

        it("passes the email to the nav's bid details object") {
            let subject = testConfirmYourBidEnterYourEmailViewController()
            let nav = subject.navigationController as! FulfillmentNavigationController
            subject.loadViewProgrammatically()

            subject.emailTextField.text = "email"
            subject.emailTextField.sendActionsForControlEvents(.EditingChanged)

            expect(nav.bidDetails.newUser.email) == "email"
        }

        it("confirm button is disabled when no email") {
            let subject = testConfirmYourBidEnterYourEmailViewController()
            let nav = FulfillmentNavigationController(rootViewController:subject)
            nav.loadViewProgrammatically()
            subject.loadViewProgrammatically()

            expect(subject.confirmButton.enabled) == false
        }

        pending("enables the enter button when an email + password is entered") {
            let subject = testConfirmYourBidEnterYourEmailViewController()
            _ = subject.navigationController as! FulfillmentNavigationController
            subject.loadViewProgrammatically()

            subject.emailTextField.text = "email@address.com"
            subject.emailTextField.sendActionsForControlEvents(.EditingChanged)

            expect(subject.confirmButton.enabled) == true
        }

    }
}
