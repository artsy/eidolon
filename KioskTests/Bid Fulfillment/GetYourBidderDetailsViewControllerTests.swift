import Quick
import Nimble
import Kiosk

class GetYourBidderDetailsViewControllerTests: QuickSpec {
    override func spec() {
        
        it("looks right by default") {
            let sut = ConfirmYourBidViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot())
        }

    }
}
