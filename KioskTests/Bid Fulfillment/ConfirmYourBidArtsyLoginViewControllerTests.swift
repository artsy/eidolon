import Quick
import Nimble
import Nimble_Snapshots
import Kiosk

class ConfirmYourBidArtsyLoginViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let subject = ConfirmYourBidArtsyLoginViewController.instantiateFromStoryboard(fulfillmentStoryboard).wrapInFulfillmentNav()
            expect(subject).to(haveValidSnapshot())
        }

    }
}
