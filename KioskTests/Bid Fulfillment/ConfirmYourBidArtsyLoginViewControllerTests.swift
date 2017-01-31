import Quick
import Nimble
import Nimble_Snapshots
@testable
import Kiosk

class ConfirmYourBidArtsyLoginViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let subject = ConfirmYourBidArtsyLoginViewController.instantiateFromStoryboard(fulfillmentStoryboard).wrapInFulfillmentNav()
            subject.loadViewProgrammatically()

            // Highlighting of the text field (as it becomes first responder) is inconsistent without this line.
            subject.view.drawHierarchy(in: CGRect.zero, afterScreenUpdates: true)

            // There's some strange button enabled state animation that's messing with the tests. Adding a tolance.
            expect(subject).to(haveValidSnapshot(usesDrawRect: true, tolerance: 0.1))
        }

        pending("looks right with an invalid password") {
            // TODO:
        }

        pending("looks right with a valid password") {
            // TODO:
        }
    }
}
