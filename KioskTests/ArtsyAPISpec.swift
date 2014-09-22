import Quick
import Nimble
import Kiosk

func beInTheFuture() -> MatcherFunc<NSDate> {
    return MatcherFunc { actualExpression, failureMessage in
        let instance = actualExpression.evaluate()
        let now = NSDate.date()
        return instance.compare(now) == NSComparisonResult.OrderedDescending
    }
}

class ArtsyAPISpec: QuickSpec {
    override func spec() {
        describe("keys", { () -> () in
            it("stubs responses for invalid keys") {
                let invalidKeys = APIKeys(key: "", secret: "")
                expect(invalidKeys.stubResponses).to(beTruthy())
            }
            
            it("doesn't stub responses for valid keys") {
                let validKeys = APIKeys(key: "key", secret: "secret")
                expect(validKeys.stubResponses).to(beFalsy())
            }
        })
        
        describe("requests") {
            beforeSuite { () -> () in
                // Force provider to stub responses
                APIKeys.sharedKeys = APIKeys(key: "", secret: "")
                Provider.sharedProvider = Provider.StubbingProvider()
            }
            
            afterSuite { () -> () in
                // Reset provider
                APIKeys.sharedKeys = APIKeys()
                Provider.sharedProvider = Provider.DefaultProvider()
            }
            
            it("returns some data") {
                setDefaultsKeys(nil, nil)
                
                var called = false
                // Make any XApp request, doesn't matter which, but make sure to subscribe so it actually fires
                XAppRequest(.Auctions).subscribeNext({ (object) -> Void in
                    called = true
                })
                
                expect(called).to(beTruthy())
            }
            
            it("gets XApp token if it doesn't exist yet") {
                setDefaultsKeys(nil, nil)
                
                XAppRequest(.Auctions).subscribeNext({ (object) -> Void in
                    // nop
                })
                
                let past = NSDate(timeIntervalSinceNow: -1000)
                expect(getDefaultsKeys().key).to(equal("some token that never expires"))
                expect(getDefaultsKeys().expiry).toNot(beNil())
                expect(getDefaultsKeys().expiry ?? past).to(beInTheFuture())
            }
            
            it("gets XApp token if it has expired") {
                let past = NSDate(timeIntervalSinceNow: -1000)
                setDefaultsKeys("some expired key", past)
                
                XAppRequest(.Auctions).subscribeNext({ (object) -> Void in
                    // nop
                })
                
                expect(getDefaultsKeys().key).to(equal("some token that never expires"))
                expect(getDefaultsKeys().expiry).toNot(beNil())
                expect(getDefaultsKeys().expiry ?? past).to(beInTheFuture())
            }
        }
    }
}

class TestKeys: EidolonKeys {
    let key: String
    let secret: String
    
    init(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }
    
    override func artsyAPIClientKey() -> String! {
        return key
    }
    
    override func artsyAPIClientSecret() -> String! {
        return secret
    }
}
