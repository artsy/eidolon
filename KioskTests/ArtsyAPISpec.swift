import Quick
import Nimble
@testable
import Kiosk
import RxSwift
import Keys
import Moya

func beInTheFuture() -> MatcherFunc<NSDate> {
    return MatcherFunc { actualExpression, failureMessage in
        let instance = try! actualExpression.evaluate()!
        let now = NSDate()
        return instance.compare(now) == NSComparisonResult.OrderedDescending
    }
}

var defaults = NSUserDefaults()

class ArtsyAPISpec: QuickSpec {
    override func spec() {

        func newXAppRequest() -> Observable<MoyaResponse> {
            return XAppRequest(ArtsyAPI.Auctions, defaults: defaults)
        }

        var disposeBag: DisposeBag!

        beforeEach {
            disposeBag = DisposeBag()
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
                setDefaultsKeys(defaults, key: nil, expiry: nil)
                
                var called = false

                // Make any XApp request, doesn't matter which, but make sure to subscribe so it actually fires
                newXAppRequest().subscribeNext { (object) in
                    called = true
                }.addDisposableTo(disposeBag)
                
                expect(called).to(beTruthy())
            }
            
            it("gets XApp token if it doesn't exist yet") {
                setDefaultsKeys(defaults, key: nil, expiry: nil)
                
                newXAppRequest().subscribeNext { (object) in
                    // nop
                }.addDisposableTo(disposeBag)
                
                let past = NSDate(timeIntervalSinceNow: -1000)
                expect(getDefaultsKeys(defaults).key).to(equal("STUBBED TOKEN!"))
                expect(getDefaultsKeys(defaults).expiry).toNot(beNil())
                expect(getDefaultsKeys(defaults).expiry ?? past).to(beInTheFuture())
            }
            
            it("gets XApp token if it has expired") {
                let past = NSDate(timeIntervalSinceNow: -1000)
                setDefaultsKeys(defaults, key: "some expired key", expiry: past)
                
                newXAppRequest().subscribeNext { (object) in
                    // nop
                }.addDisposableTo(disposeBag)
                
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
