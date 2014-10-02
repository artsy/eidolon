import Quick
import Nimble

class ConfirmYourBidEnterYourEmailViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = ConfirmYourBidEnterYourEmailViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot(named:"default"))
        }

        it("passes the email to the nav's bid details object") {
            let sut = ConfirmYourBidEnterYourEmailViewController.instantiateFromStoryboard()
            let nav = FulfillmentNavigationController(rootViewController:sut)
            nav!.loadViewProgrammatically()
            sut.loadViewProgrammatically()

            sut.emailTextField.text = "email"
            sut.emailTextField.sendActionsForControlEvents(.EditingChanged)

            expect(nav!.bidDetails.newUser.email) == "email"
        }

        it("confirm button is disabled when no email") {
            let sut = ConfirmYourBidEnterYourEmailViewController.instantiateFromStoryboard()
            let nav = FulfillmentNavigationController(rootViewController:sut)
            nav!.loadViewProgrammatically()
            sut.loadViewProgrammatically()

            expect(sut.confirmButton.enabled) == false
        }

        it("enables the enter button when an email is entered") {
            let sut = ConfirmYourBidEnterYourEmailViewController.instantiateFromStoryboard()
            let nav = FulfillmentNavigationController(rootViewController:sut)
            nav!.loadViewProgrammatically()
            sut.loadViewProgrammatically()

            sut.emailTextField.text = "email@address.com"
            sut.emailTextField.sendActionsForControlEvents(.EditingChanged)

            expect(sut.confirmButton.enabled) == true

        }

    }
}
