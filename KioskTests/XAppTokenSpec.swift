import Quick
import Nimble
import Kiosk

class XAppTokenSpec: QuickSpec {
    override func spec() {
        let token = XAppToken()
        
        it("returns correct data") {
            let key = "some key"
            let expiry = NSDate(timeIntervalSinceNow: 1000)
            setDefaultsKeys(key, expiry)
            
            expect(token.token).to(equal(key))
            expect(token.expiry).to(equal(expiry))
        }
        
        it("correctly calculates validity for expired tokens") {
            let key = "some key"
            let past = NSDate(timeIntervalSinceNow: -1000)
            setDefaultsKeys(key, past)
            
            expect(token.isValid).to(beFalsy())
        }
        
        it("correctly calculates validity for non-expired tokens") {
            let key = "some key"
            let future = NSDate(timeIntervalSinceNow: 1000)
            setDefaultsKeys(key, future)
            
            expect(token.isValid).to(beTruthy())
        }
        
        it("properly calculates validity for missing tokens") {
            setDefaultsKeys(nil, nil)
            
            expect(token.isValid).to(beFalsy())
        }
    }
}
