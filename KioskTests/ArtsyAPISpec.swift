import Quick
import Nimble
import Kiosk
import ReactiveCocoa
import Pods_Kiosk
import Moya

func beInTheFuture() -> MatcherFunc<NSDate> {
    return MatcherFunc { actualExpression, failureMessage in
        let instance = actualExpression.evaluate()!
        let now = NSDate()
        return instance.compare(now) == NSComparisonResult.OrderedDescending
    }
}

var defaults = NSUserDefaults()

class ArtsyAPISpec: QuickSpec {

    override func spec() {

        func newXAppRequest() -> RACSignal {
            return XAppRequest(ArtsyAPI.Auctions, method: Moya.DefaultMethod(), parameters: Moya.DefaultParameters(), defaults: defaults)
        }

        describe("keys", {
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
            beforeSuite { 
                // Force provider to stub responses
                APIKeys.sharedKeys = APIKeys(key: "", secret: "")
                Provider.sharedProvider = Provider.StubbingProvider()
            }
            
            afterSuite {
                // Reset provider
                APIKeys.sharedKeys = APIKeys()
                Provider.sharedProvider = Provider.DefaultProvider()
            }
            
            it("returns some data") {
                setDefaultsKeys(defaults, nil, nil)
                
                var called = false

                // Make any XApp request, doesn't matter which, but make sure to subscribe so it actually fires
                newXAppRequest().subscribeNext({ (object) -> Void in
                    called = true
                })
                
                expect(called).to(beTruthy())
            }
            
            it("gets XApp token if it doesn't exist yet") {
                setDefaultsKeys(defaults, nil, nil)
                
                newXAppRequest().subscribeNext({ (object) -> Void in
                    // nop
                })
                
                let past = NSDate(timeIntervalSinceNow: -1000)
                expect(getDefaultsKeys(defaults).key).to(equal("STUBBED TOKEN!"))
                expect(getDefaultsKeys(defaults).expiry).toNot(beNil())
                expect(getDefaultsKeys(defaults).expiry ?? past).to(beInTheFuture())
            }
            
            it("gets XApp token if it has expired") {
                let past = NSDate(timeIntervalSinceNow: -1000)
                setDefaultsKeys(defaults, "some expired key", past)
                
                newXAppRequest().subscribeNext({ (object) -> Void in
                    // nop
                })
                
                expect(getDefaultsKeys(defaults).key).to(equal("STUBBED TOKEN!"))
                expect(getDefaultsKeys(defaults).expiry).toNot(beNil())
                expect(getDefaultsKeys(defaults).expiry ?? past).to(beInTheFuture())
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
