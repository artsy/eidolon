import Quick
import Nimble
import Kiosk

class XAppTokenSpec: QuickSpec {
    override func spec() {
        let defaults = NSUserDefaults()
        let token = XAppToken()
        
        it("returns correct data") {
            let key = "some key"
            let expiry = NSDate(timeIntervalSinceNow: 1000)
            setDefaultsKeys(defaults, key: key, expiry: expiry)
            
            expect(token.token).to(equal(key))
            expect(token.expiry).to(equal(expiry))
        }
        
        it("correctly calculates validity for expired tokens") {
            let key = "some key"
            let past = NSDate(timeIntervalSinceNow: -1000)
            setDefaultsKeys(defaults, key: key, expiry: past)
            
            expect(token.isValid).to(beFalsy())
        }
        
        it("correctly calculates validity for non-expired tokens") {
            let key = "some key"
            let future = NSDate(timeIntervalSinceNow: 1000)
            setDefaultsKeys(defaults, key: key, expiry: future)
            
            expect(token.isValid).to(beTruthy())
        }
        
        it("correctly calculates validity for empty keys") {
            let key = ""
            let future = NSDate(timeIntervalSinceNow: 1000)
            setDefaultsKeys(defaults, key: key, expiry: future)
            
            expect(token.isValid).to(beFalsy())
        }
        
        it("properly calculates validity for missing tokens") {
            setDefaultsKeys(defaults, key: nil, expiry: nil)
            
            expect(token.isValid).to(beFalsy())
        }
    }
}
