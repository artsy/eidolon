import Quick
import Nimble

class ConfirmYourBidPINTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = ConfirmYourBidPINViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot(named:"default"))
        }

    }
}
