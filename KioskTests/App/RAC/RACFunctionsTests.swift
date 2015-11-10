import Quick
import Nimble
@testable
import Kiosk
import RxSwift

class RACFunctionsTests: QuickSpec {
    override func spec() {
        describe("email address check") {
            it("requires @") {
                let valid = stringIsEmailAddress("ashartsymail.com") as! Bool
                expect(valid) == false
            }

            it("requires name") {
                let valid = stringIsEmailAddress("@artsymail.com") as! Bool
                expect(valid) == false
            }

            it("requires domain") {
                let valid = stringIsEmailAddress("ash@.com") as! Bool
                expect(valid) == false
            }

            it("requires tld") {
                let valid = stringIsEmailAddress("ash@artsymail") as! Bool
                expect(valid) == false
            }

            it("validates good emails") {
                let valid = stringIsEmailAddress("ash@artsymail.com") as! Bool
                expect(valid) == true
            }
        }

        describe("presenting cents as dollars") {
            it("works with valid input") {
                let input = 1_000_00
                let formattedDolars = centsToPresentableDollarsString(input) as! String
                expect(formattedDolars) == "$1,000"
            }

            it("returns the empty string on invalid input") {
                let input = "something not a number"
                let formattedDolars = centsToPresentableDollarsString(input) as! String
                expect(formattedDolars) == ""
            }
        }

        describe("zero length string check") {
            it("returns true for zero-length strings") {
                let valid = isZeroLengthString("") as! Bool
                expect(valid) == true
            }

            it("returns false for non zero-length strings") {
                let valid = isZeroLengthString("something else") as! Bool
                expect(valid) == false
            }

            it("returns false for non zero-length strings of spaces") {
                let valid = isZeroLengthString("    ") as! Bool
                expect(valid) == false
            }
        }

        describe("string length range check") {
            it("returns true when the string length is within the specified range") {
                let valid = isStringLengthIn(1..<5)(string: "hi") as! Bool
                expect(valid) == true
            }

            it("returns false when the string length is not within the specified range") {
                let valid = isStringLengthIn(3..<5)(string: "hi") as! Bool
                expect(valid) == false
            }
        }

        describe("string length check") {
            it("returns true when the string length is the specified length") {
                let valid = isStringOfLength(2)(string: "hi") as! Bool
                expect(valid) == true
            }

            it("returns false when the string length is not the specified length") {
                let valid = isStringOfLength(3)(string: "hi") as! Bool
                expect(valid) == false
            }
        }

        describe("string length minimum check") {
            it("returns true when the string length is the specified length") {
                let valid = isStringLengthAtLeast(2)(string: "hi") as! Bool
                expect(valid) == true
            }

            it("returns true when the string length is more than the specified length") {
                let valid = isStringLengthAtLeast(1)(string: "hi") as! Bool
                expect(valid) == true
            }

            it("returns false when the string length is less than the specified length") {
                let valid = isStringLengthAtLeast(3)(string: "hi") as! Bool
                expect(valid) == false
            }
        }

        describe("string length one of check") {
            it("returns true when the string length is one of the specified lengths") {
                let valid = isStringLengthOneOf([0,2])(string: "hi") as! Bool
                expect(valid) == true
            }

            it("returns false when the string length is not one of the specified lengths") {
                let valid = isStringLengthOneOf([0,1])(string: "hi") as! Bool
                expect(valid) == false
            }

            it("returns false when the string length is between the specified lengths") {
                let valid = isStringLengthOneOf([1,3])(string: "hi") as! Bool
                expect(valid) == false
            }
        }
    }
}
