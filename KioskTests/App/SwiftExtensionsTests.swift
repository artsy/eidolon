import Quick
import Nimble
import Kiosk
import ReactiveCocoa

class SwiftExtensionsTests: QuickSpec {
    override func spec() {
        describe("String") {
            it("converts to UInt") {
                let input = "4"
                expect(input.toUInt()) == 4
            }

            it("returns nil if no conversion is available") {
                let input = "not a number"
                expect(input.toUInt()).to( beNil() )
            }

            it("uses a default if no conversion is available") {
                let input = "not a number"
                expect(input.toUInt(defaultValue: 4)) == 4
            }
        }
    }
}