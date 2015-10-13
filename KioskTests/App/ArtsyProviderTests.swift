import Quick
import Nimble
import ReactiveCocoa
@testable
import Kiosk
import Moya

class ArtsyProviderTests: QuickSpec {
    override func spec() {
        let fakeEndpointsClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
            return Endpoint<ArtsyAPI>(URL: url(target), sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        }

        var fakeOnlineSignal: RACSubject!
        var subject: ArtsyProvider<ArtsyAPI>!
        var defaults: NSUserDefaults!

        beforeEach {
            fakeOnlineSignal = RACSubject()
            subject = ArtsyProvider<ArtsyAPI>(endpointClosure: fakeEndpointsClosure, stubClosure: MoyaProvider<ArtsyAPI>.ImmediatelyStub, onlineSignal: fakeOnlineSignal)

            // We fake our defaults to avoid actually hitting the network
            defaults = NSUserDefaults()
            defaults.setObject(NSDate.distantFuture(), forKey: "TokenExpiry")
            defaults.setObject("Some key", forKey: "TokenKey")
        }

        it ("waits for the internet to happen before continuing with network operations") {
            var called = false

            XAppRequest(.Ping, provider: subject, defaults: defaults).subscribeNext { _ -> Void in
                called = true
            }

            expect(called) == false

            // Fake getting online
            fakeOnlineSignal.sendCompleted()

            expect(called) == true
        }
    }
}