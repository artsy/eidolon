import Quick
import Nimble
import RxSwift
@testable
import Kiosk
import Moya

class ArtsyProviderTests: QuickSpec {
    override func spec() {
        let fakeEndpointsClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
            return Endpoint<ArtsyAPI>(url: url(target), sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        }

        var fakeOnline: PublishSubject<Bool>!
        var subject: Networking!
        var defaults: UserDefaults!

        beforeEach {
            fakeOnline = PublishSubject<Bool>()
            subject = Networking(provider: OnlineProvider<ArtsyAPI>(endpointClosure: fakeEndpointsClosure, stubClosure: MoyaProvider<ArtsyAPI>.immediatelyStub, online: fakeOnline.asObservable()))

            // We fake our defaults to avoid actually hitting the network
            defaults = UserDefaults()
            defaults.set(NSDate.distantFuture, forKey: "TokenExpiry")
            defaults.set("Some key", forKey: "TokenKey")
        }

        it ("waits for the internet to happen before continuing with network operations") {
            var called = false

            let disposeBag = DisposeBag()
            subject.request(ArtsyAPI.ping, defaults: defaults).subscribe(onNext: { _ in
                called = true
            }).addDisposableTo(disposeBag)

            expect(called) == false

            // Fake getting online
            fakeOnline.onNext(true)

            expect(called) == true
        }
    }
}
