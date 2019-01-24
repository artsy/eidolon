import Foundation
import Quick
import Nimble
@testable
import Kiosk
import RxSwift
import Keys
import Moya

func beInTheFuture() -> Predicate<Date> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in
        let instance = try! actualExpression.evaluate()!
        let now = Date()
        return instance.compare(now) == ComparisonResult.orderedDescending
    }
}

class ArtsyAPISpec: QuickSpec {
    override func spec() {
        var defaults: UserDefaults!

        var disposeBag: DisposeBag!
        var networking: Networking!

        func newXAppRequest() -> Observable<Moya.Response> {
            return networking.request(ArtsyAPI.auctions)
        }

        beforeEach {
            defaults = UserDefaults()
            networking = Networking.newStubbingNetworking()
        }

        beforeEach {
            disposeBag = DisposeBag()
        }

        describe("keys") {
            it("stubs responses for invalid keys") {
                let invalidKeys = APIKeys(key: "", secret: "")
                expect(invalidKeys.stubResponses).to(beTruthy())
            }
            
            it("doesn't stub responses for valid keys") {
                let validKeys = APIKeys(key: "key", secret: "secret")
                expect(validKeys.stubResponses).to(beFalsy())
            }
        }
        
        describe("requests") {
            beforeSuite { 
                // Force provider to stub responses
                APIKeys.sharedKeys = APIKeys(key: "", secret: "")
                UserDefaults.standard.set("US", forKey: PhoneNumberRegionKey)
            }
            
            afterSuite {
                // Reset provider
                APIKeys.sharedKeys = APIKeys()
            }
            
            it("returns some data") {
                setDefaultsKeys(defaults, key: nil, expiry: nil)
                
                var called = false

                // Make any XApp request, doesn't matter which, but make sure to subscribe so it actually fires
                newXAppRequest().subscribe(onNext: { (object) in
                    called = true
                }).disposed(by: disposeBag)
                
                expect(called).to(beTruthy())
            }
            
            it("gets XApp token if it doesn't exist yet") {
                setDefaultsKeys(defaults, key: nil, expiry: nil)

                waitUntil { done in
                    newXAppRequest().subscribe(onNext: { (object) in
                        // nop
                        done()
                    }).disposed(by: disposeBag)
                }
                
                let past = Date(timeIntervalSinceNow: -1000)
                expect(getDefaultsKeys(defaults).key).to(equal("STUBBED TOKEN!"))
                expect(getDefaultsKeys(defaults).expiry).toNot(beNil())
                expect(getDefaultsKeys(defaults).expiry ?? past).to(beInTheFuture())
            }
            
            it("gets XApp token if it has expired") {
                let past = Date(timeIntervalSinceNow: -1000)
                setDefaultsKeys(defaults, key: "some expired key", expiry: past)
                
                newXAppRequest().subscribe(onNext: { (object) in
                    // nop
                }).disposed(by: disposeBag)
                
                expect(getDefaultsKeys(defaults).key).to(equal("STUBBED TOKEN!"))
                expect(getDefaultsKeys(defaults).expiry).toNot(beNil())
                expect(getDefaultsKeys(defaults).expiry ?? past).to(beInTheFuture())
            }

            it("formats phone numbers as E.164 encoded") {
                let target = ArtsyAPI.createUser(email: "user@example.com", password: "password", phone: "5555555555", postCode: "12345", name: "Fname Lname")
                expect(target.parameters!["phone"] as! String?) == "+15555555555"
            }

            it("leaves paddle number unformatted") {
                let bidDetails = testBidDetails()
                let subject = try! bidDetails.authenticatedNetworking(provider: networking).toBlocking().first()
                let endpoint = subject!.provider.provider.endpointClosure(ArtsyAuthenticatedAPI.me)
                if case .requestParameters(parameters: let params, encoding: _) = endpoint.task {
                    expect(params["number"] as? String) == bidDetails.paddleNumber.value
                } else {
                    fail("Couldn't parse parameters")
                }
            }

            it("formats phone numbers") {
                let bidDetails = testBidDetails()
                bidDetails.authNumberType = .phoneNumber
                bidDetails.paddleNumber.value = "5555555555"
                let subject = try! bidDetails.authenticatedNetworking(provider: networking).toBlocking().first()
                let endpoint = subject!.provider.provider.endpointClosure(ArtsyAuthenticatedAPI.me)
                if case .requestParameters(parameters: let params, encoding: _) = endpoint.task {
                    expect(params["number"] as? String) == "+15555555555"
                } else {
                    fail("Couldn't parse parameters")
                }
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
    
    override var artsyAPIClientKey: String {
        return key
    }
    
    override var artsyAPIClientSecret: String {
        return secret
    }
}
