import Quick
import Nimble
import Kiosk

class ConfirmYourBidViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = ConfirmYourBidViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot())
        }

    }
}
