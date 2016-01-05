import Quick
import Nimble
import RxSwift
@testable
import Kiosk
import Moya

class ArtsyProviderTests: QuickSpec {
    override func spec() {
        let fakeEndpointsClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
            return Endpoint<ArtsyAPI>(URL: url(target), sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        }

        var fakeOnline: PublishSubject<Bool>!
        var subject: Networking!
        var defaults: NSUserDefaults!

        beforeEach {
            fakeOnline = PublishSubject<Bool>()
            subject = Networking(provider: OnlineProvider<ArtsyAPI>(endpointClosure: fakeEndpointsClosure, stubClosure: MoyaProvider<ArtsyAPI>.ImmediatelyStub, online: fakeOnline.asObservable()))

            // We fake our defaults to avoid actually hitting the network
            defaults = NSUserDefaults()
            defaults.setObject(NSDate.distantFuture(), forKey: "TokenExpiry")
            defaults.setObject("Some key", forKey: "TokenKey")
        }

        it ("waits for the internet to happen before continuing with network operations") {
            var called = false

            let disposeBag = DisposeBag()
            subject.request(ArtsyAPI.Ping, defaults: defaults).subscribeNext { _ in
                called = true
            }.addDisposableTo(disposeBag)

            expect(called) == false

            // Fake getting online
            fakeOnline.onNext(true)

            expect(called) == true
        }
    }
}