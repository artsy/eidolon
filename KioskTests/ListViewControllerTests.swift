import Quick
import Nimble

class ListingsViewControllerTests: QuickSpec {
    override func spec() {
        
        it("presents a view controller when showModal is called") {
            // As it's a UINav it needs to be in the real view herarchy 
            
            let window = UIApplication.sharedApplication().delegate!.window!
            let sut = ListingsViewController()
            window!.rootViewController = sut

            sut.allowAnimations = false;
            sut.showModal("")
            
            expect(sut.presentedViewController!) != nil
        }
        
    }
}
