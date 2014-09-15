import Quick
import Nimble
import Kiosk

class EnterYourBidderDetailsViewControllerTests: QuickSpec {
    override func spec() {
        it("looks right by default") {
            let sut  = EnterYourBidderDetailsViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot())
        }

    }
}
