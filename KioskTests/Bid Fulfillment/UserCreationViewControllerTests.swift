import Quick
import Nimble

class UserCreationViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = UserCreationViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot())
        }

    }
}
