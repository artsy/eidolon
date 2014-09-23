import Quick
import Nimble

class SwipeCreditCardViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = SwipeCreditCardViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot())
        }


    }
}
