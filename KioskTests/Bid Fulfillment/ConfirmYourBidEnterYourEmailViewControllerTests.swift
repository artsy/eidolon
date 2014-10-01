import Quick
import Nimble

class ConfirmYourBidEnterYourEmailViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = ConfirmYourBidEnterYourEmailViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot(named:"default"))
        }

    }
}
