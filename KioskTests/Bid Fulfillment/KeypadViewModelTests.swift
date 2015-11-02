import Quick
import Nimble
import ReactiveCocoa
@testable
import Kiosk

class KeypadViewModelTestClass: NSObject {
    // Start with invalid data
    dynamic var stringValue = "something invalid"
    dynamic var intValue = -1
}

class KeypadViewModelTests: QuickSpec {
    override func spec() {
        var subject: KeypadViewModel!
        var testHarness: KeypadViewModelTestClass!
        
        beforeEach {
            subject = KeypadViewModel()
            testHarness = KeypadViewModelTestClass()
        }
        
        it("it has default values") {
            RAC(testHarness, "stringValue") <~ subject.stringValueSignal
            RAC(testHarness, "intValue") <~ subject.intValueSignal
            
            expect(testHarness.intValue) == 0
            expect(testHarness.stringValue) == ""
        }
        
        it("adds digits") {
            waitUntil { (done) -> Void in
                RAC(testHarness, "stringValue") <~ subject.stringValueSignal
                RAC(testHarness, "intValue") <~ subject.intValueSignal
                
                [1,3,3,7].reduce(RACSignal.empty(), combine: { (signal, input) -> RACSignal in
                    signal.then { subject.addDigitCommand.execute(input) }
                }).subscribeCompleted { () -> Void in
                    expect(testHarness.intValue) == 1337
                    expect(testHarness.stringValue) == "1337"
                    
                    done()
                }
            }
        }

        it("has a max int, but not max string, value") {
            waitUntil { (done) -> Void in
                RAC(testHarness, "stringValue") <~ subject.stringValueSignal
                RAC(testHarness, "intValue") <~ subject.intValueSignal

                [1,3,3,3,3,3,3,3,3,3,3,3,7].reduce(RACSignal.empty(), combine: { (signal, input) -> RACSignal in
                    signal.then { subject.addDigitCommand.execute(input) }
                }).subscribeCompleted { () -> Void in
                    expect(testHarness.intValue) == 1333333
                    expect(testHarness.stringValue) == "1333333333337"

                    done()
                }
            }
        }
        
        it("handles prepended zeros") {
            waitUntil { (done) -> Void in
                RAC(testHarness, "stringValue") <~ subject.stringValueSignal
                RAC(testHarness, "intValue") <~ subject.intValueSignal
                
                [0,1,3,3,7].reduce(RACSignal.empty(), combine: { (signal, input) -> RACSignal in
                    signal.then { subject.addDigitCommand.execute(input) }
                }).subscribeCompleted { () -> Void in
                    expect(testHarness.intValue) == 1337
                    expect(testHarness.stringValue) == "01337"
                    
                    done()
                }
            }
        }
        
        it("clears") {
            waitUntil { (done) -> Void in
                RAC(testHarness, "stringValue") <~ subject.stringValueSignal
                RAC(testHarness, "intValue") <~ subject.intValueSignal
                
                RACSignal.empty().then {
                    subject.addDigitCommand.execute(1)
                }.then {
                    subject.clearCommand.execute(nil)
                }.subscribeCompleted { () -> Void in
                    expect(testHarness.intValue) == 0
                    expect(testHarness.stringValue) == ""
                    
                    done()
                }
            }
        }
        
        it("deletes") {
            waitUntil { (done) -> Void in
                RAC(testHarness, "stringValue") <~ subject.stringValueSignal
                RAC(testHarness, "intValue") <~ subject.intValueSignal
                
                [1,3,3].reduce(RACSignal.empty(), combine: { (signal, input) -> RACSignal in
                    signal.then { subject.addDigitCommand.execute(input) }
                }).then {
                    subject.deleteCommand.execute(nil)
                }.subscribeCompleted { () -> Void in
                    expect(testHarness.intValue) == 13
                    expect(testHarness.stringValue) == "13"
                    
                    done()
                }
            }
        }
    }
}
