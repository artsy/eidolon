import Quick
import Nimble
import Kiosk

class YourBidderDetailsViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = YourBidderDetailsViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot())
        }

    }
}
