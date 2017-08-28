import Quick
import Nimble
import RxSwift
import RxOptional

@testable
import Kiosk

let Empty = "empty"
let NonEmpty = "nonEmpty"

// Workaround due to limitations in the compiler. See: https://twitter.com/jckarter/status/636969467713458176
class AnyOccupiable: NSObject, Occupiable {
    let value: Occupiable

    init(value: Occupiable) {
        self.value = value
        super.init()
    }

    var isEmpty: Bool {
        return value.isEmpty
    }
    var isNotEmpty: Bool {
        return value.isNotEmpty
    }
}

class SwiftExtensionsConfiguration: QuickConfiguration {

    override class func configure(_ configuration: Configuration) {
        sharedExamples("an Occupiable") { (sharedExampleContext: @escaping SharedExampleContext) in
            var empty: AnyOccupiable?
            var nonEmpty: AnyOccupiable?

            beforeEach {
                let context = sharedExampleContext()
                empty = context[Empty] as? AnyOccupiable
                nonEmpty = context[NonEmpty] as? AnyOccupiable
            }

            it("returns isNilOrEmpty as true when nil") {
                let subject: AnyOccupiable? = nil
                expect(subject.isNilOrEmpty).to( beTrue() )
            }

            it("returns isNilOrEmpty as true when empty") {
                let subject = empty
                expect(subject.isNilOrEmpty).to( beTrue() )
            }

            it("returns isNilOrEmpty as false when not empty") {
                let subject = nonEmpty
                expect(subject.isNilOrEmpty).to( beFalse() )
            }

            it("returns isNotNilNotEmpty as false when nil") {
                let subject: AnyOccupiable? = nil
                expect(subject.isNotNilNotEmpty).to( beFalse() )
            }

            it("returns isNotNilNotEmpty as false when empty") {
                let subject = empty
                expect(subject.isNotNilNotEmpty).to( beFalse() )
            }

            it("returns isNotNilNotEmpty as true when not empty") {
                let subject = nonEmpty
                expect(subject.isNotNilNotEmpty).to( beTrue() )
            }

            describe("unwrapped") {
                it("returns isNotEmpty as true when not not empty") {
                    let subject = nonEmpty!
                    expect(subject.isNotEmpty).to( beTrue() )
                }

                it("returns isNotEmpty as false when empty") {
                    let subject = empty!
                    expect(subject.isNotEmpty).to( beFalse() )
                }
            }
        }
    }
}

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
                expect(input.toUInt(withDefault: 4)) == 4
            }
        }


        describe("String") {
            itBehavesLike("an Occupiable") { [ Empty: AnyOccupiable(value: ""), NonEmpty: AnyOccupiable(value: "hi") ] }
        }

        describe("Array") {
            itBehavesLike("an Occupiable") { [ Empty: AnyOccupiable(value: Array<String>()), NonEmpty: AnyOccupiable(value: ["hi"]) ] }
        }

        describe("Dictionary") {
            itBehavesLike("an Occupiable") { [ Empty: AnyOccupiable(value: Dictionary<String, String>()), NonEmpty: AnyOccupiable(value: ["hi": "yo"]) ] }
        }
    }
}
