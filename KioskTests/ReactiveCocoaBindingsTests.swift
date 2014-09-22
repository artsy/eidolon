import Quick
import Nimble
import Kiosk

class BindingsTestClass: NSObject {
    dynamic var value = ""
}

class ReactiveCocoaBindingsTests: QuickSpec {
    override func spec() {
        it("correctly binds") {
            var lhs = BindingsTestClass()
            var rhs = BindingsTestClass()
            
            lhs.value = "Daedalus Demands"
            
            RACObserve(lhs, "value") ~> RAC(rhs, "value")
            
            expect(rhs.value).to(equal(lhs.value))
            
            lhs.value = "Icarus Abides"
            expect(rhs.value).to(equal(lhs.value))
        }
    }
}
