import Quick
import Nimble

class YouAreTheHighestBidderViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = YouAreTheHighestBidderViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot())
        }

    }
}
