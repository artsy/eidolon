import Quick
import Nimble
import RxNimble
@testable
import Kiosk
import Nimble_Snapshots

func testConfirmYourBidEnterYourEmailViewController() -> ConfirmYourBidEnterYourEmailViewController {
    return ConfirmYourBidEnterYourEmailViewController.instantiateFromStoryboard(fulfillmentStoryboard).wrapInFulfillmentNav() as! ConfirmYourBidEnterYourEmailViewController
}

let window = UIWindow()

class ConfirmYourBidEnterYourEmailViewControllerTests: QuickSpec {
    override func spec() {

        beforeSuite {
            // Required for all snapshot test cases, otherwise it blows up: https://github.com/facebook/ios-snapshot-test-case/blob/fbb2d277cda66350487a88e318cd5a3457738ddd/FBSnapshotTestCase/Categories/UIApplication%2BStrictKeyWindow.m#L18-L23
            window.makeKeyAndVisible()
        }

        it("looks right by default") {
            let subject = testConfirmYourBidEnterYourEmailViewController()
            _ = subject.view
            subject.loadViewProgrammatically()
            // Highlighting of the text field (as it becomes first responder) is inconsistent without this line.
            subject.view.drawHierarchy(in: CGRect.zero, afterScreenUpdates: true)

            expect(subject).to(haveValidSnapshot(usesDrawRect: true))
        }

        it("passes the email to the nav's bid details object") {
            let subject = testConfirmYourBidEnterYourEmailViewController()
            let nav = subject.navigationController as! FulfillmentNavigationController
            subject.loadViewProgrammatically()

            subject.emailTextField.text = "email"
            subject.emailTextField.sendActions(for: .editingChanged)

            expect(nav.bidDetails.newUser.email) == "email"
        }

        it("confirm button is disabled when no email") {
            let subject = testConfirmYourBidEnterYourEmailViewController()
            let nav = FulfillmentNavigationController(rootViewController:subject)
            nav.auctionID = testAuctionID
            nav.loadViewProgrammatically()
            subject.loadViewProgrammatically()

            expect(subject.confirmButton.isEnabled) == false
        }

        pending("enables the enter button when an email + password is entered") {
            let subject = testConfirmYourBidEnterYourEmailViewController()
            _ = subject.navigationController as! FulfillmentNavigationController
            subject.loadViewProgrammatically()

            subject.emailTextField.text = "email@address.com"
            subject.emailTextField.sendActions(for: .editingChanged)

            expect(subject.confirmButton.isEnabled) == true
        }

    }
}
