import Quick
import Nimble

class YourBidderDetailsViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = YourBidderDetailsViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot())
        }

    }
}
