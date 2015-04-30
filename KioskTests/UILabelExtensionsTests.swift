import Quick
import Nimble
import Kiosk

class UILabelExtensionsTests: QuickSpec {
    override func spec() {
        it("makes labels non-opaque") {
            let subject = UILabel()
            subject.opaque = true
            subject.makeTransparent()

            expect(subject.opaque) == false
        }

        it("makes labels with clear backgrounds") {
            let subject = UILabel()
            subject.backgroundColor = .redColor()
            subject.makeTransparent()

            expect(subject.backgroundColor) == .clearColor()
        }
    }
}
