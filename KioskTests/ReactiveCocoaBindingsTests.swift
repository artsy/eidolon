import Quick
import Nimble
import ReactiveCocoa
import Kiosk
import Swift_RAC_Macros

class BindingsTestClass: NSObject {
    dynamic var value = ""
}

class ReactiveCocoaBindingsTests: QuickSpec {
    override func spec() {
        it("correctly binds left to right") {
            var lhs = BindingsTestClass()
            var rhs = BindingsTestClass()
            
            lhs.value = "Daedalus Demands"
            
            RACObserve(lhs, "value") ~> RAC(rhs, "value")
            
            expect(rhs.value).to(equal(lhs.value))
            
            lhs.value = "Icarus Abides"
            expect(rhs.value).to(equal(lhs.value))
        }
        
        it("correctly binds right to left") {
            var lhs = BindingsTestClass()
            var rhs = BindingsTestClass()
            
            lhs.value = "Daedalus Demands"
            
            RAC(rhs, "value") <~ RACObserve(lhs, "value")
            
            expect(rhs.value).to(equal(lhs.value))
            
            lhs.value = "Icarus Abides"
            expect(rhs.value).to(equal(lhs.value))
        }
    }
}
