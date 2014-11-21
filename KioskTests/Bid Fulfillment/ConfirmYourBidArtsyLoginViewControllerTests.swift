import Quick
import Nimble
import Nimble_Snapshots
import Kiosk

class ConfirmYourBidArtsyLoginViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = ConfirmYourBidArtsyLoginViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot())
        }

    }
}
