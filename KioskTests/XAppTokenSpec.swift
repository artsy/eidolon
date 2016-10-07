import Quick
import Nimble
@testable
import Kiosk

class XAppTokenSpec: QuickSpec {
    override func spec() {
        var defaults: UserDefaults!
        var token: XAppToken!

        beforeEach {
            defaults = UserDefaults()
            token = XAppToken(defaults: defaults)
        }
        
        it("returns correct data") {
            let key = "some key"
            let expiry = Date(timeIntervalSinceNow: 1000)
            setDefaultsKeys(defaults, key: key, expiry: expiry)
            
            expect(token.token).to( equal(key) )
            expect(token.expiry).to( beCloseTo(expiry, within: 1) )
        }
        
        it("correctly calculates validity for expired tokens") {
            let key = "some key"
            let past = Date(timeIntervalSinceNow: -1000)
            setDefaultsKeys(defaults, key: key, expiry: past)
            
            expect(token.isValid).to( beFalsy() )
        }
        
        it("correctly calculates validity for non-expired tokens") {
            let key = "some key"
            let future = Date(timeIntervalSinceNow: 1000)
            setDefaultsKeys(defaults, key: key, expiry: future)
            
            expect(token.isValid).to( beTruthy() )
        }
        
        it("correctly calculates validity for empty keys") {
            let key = ""
            let future = Date(timeIntervalSinceNow: 1000)
            setDefaultsKeys(defaults, key: key, expiry: future)
            
            expect(token.isValid).to( beFalsy() )
        }
        
        it("properly calculates validity for missing tokens") {
            setDefaultsKeys(defaults, key: nil, expiry: nil)
            
            expect(token.isValid).to( beFalsy() )
        }
    }
}
