import Quick
import Nimble
@testable
import Kiosk

class UILabelExtensionsTests: QuickSpec {
    override func spec() {
        it("makes labels non-opaque") {
            let subject = UILabel()
            subject.isOpaque = true
            subject.makeTransparent()

            expect(subject.isOpaque) == false
        }

        it("makes labels with clear backgrounds") {
            let subject = UILabel()
            subject.backgroundColor = .red
            subject.makeTransparent()

            expect(subject.backgroundColor) == .clear
        }
    }
}
