import Quick
import Nimble
import Kiosk

class AppViewControllerTests: QuickSpec {
    override func spec() {
        it("looks right offline") {
            let sut: AppViewController?

            expect(sut).to(beNil())
        }
    }
}
