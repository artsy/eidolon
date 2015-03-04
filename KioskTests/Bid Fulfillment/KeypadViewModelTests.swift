import Quick
import Nimble
import ReactiveCocoa
import Swift_RAC_Macros
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
            RAC(testHarness, "stringValue") <~ subject.stringValueSignal
            RAC(testHarness, "intValue") <~ subject.intValueSignal
            
            var completed = false
            
            RACSignal.empty().then {
                subject.addDigitCommand.execute(1)
            }.then {
                subject.addDigitCommand.execute(3)
            }.then {
                subject.addDigitCommand.execute(3)
            }.then {
                subject.addDigitCommand.execute(7)
            }.subscribeCompleted { () -> Void in
                expect(testHarness.intValue) == 1337
                expect(testHarness.stringValue) == "1337"
                
                completed = true
            }
            
            expect{ completed }.toEventually( beTruthy() )
        }
        
        it("handles prepended zeros") {
            RAC(testHarness, "stringValue") <~ subject.stringValueSignal
            RAC(testHarness, "intValue") <~ subject.intValueSignal
            
            var completed = false
            
            RACSignal.empty().then {
                subject.addDigitCommand.execute(0)
            }.then {
                subject.addDigitCommand.execute(1)
            }.then {
                subject.addDigitCommand.execute(3)
            }.then {
                subject.addDigitCommand.execute(3)
            }.then {
                subject.addDigitCommand.execute(7)
            }.subscribeCompleted { () -> Void in
                expect(testHarness.intValue) == 1337
                expect(testHarness.stringValue) == "01337"
                
                completed = true
            }
            
            expect{ completed }.toEventually( beTruthy() )
        }
        
        it("clears") {
            RAC(testHarness, "stringValue") <~ subject.stringValueSignal
            RAC(testHarness, "intValue") <~ subject.intValueSignal
            
            var completed = false
            
            RACSignal.empty().then {
                subject.addDigitCommand.execute(1)
            }.then {
                subject.clearCommand.execute(nil)
            }.subscribeCompleted { () -> Void in
                expect(testHarness.intValue) == 0
                expect(testHarness.stringValue) == ""
                
                completed = true
            }
            
            expect{ completed }.toEventually( beTruthy() )
        }
        
        it("deletes") {
            RAC(testHarness, "stringValue") <~ subject.stringValueSignal
            RAC(testHarness, "intValue") <~ subject.intValueSignal
            
            var completed = false
            
            RACSignal.empty().then {
                subject.addDigitCommand.execute(1)
            }.then {
                subject.addDigitCommand.execute(3)
            }.then {
                subject.addDigitCommand.execute(3)
            }.then {
                subject.deleteCommand.execute(nil)
            }.subscribeCompleted { () -> Void in
                expect(testHarness.intValue) == 13
                expect(testHarness.stringValue) == "13"
                
                completed = true
            }
            
            expect{ completed }.toEventually( beTruthy() )
        }
    }
}