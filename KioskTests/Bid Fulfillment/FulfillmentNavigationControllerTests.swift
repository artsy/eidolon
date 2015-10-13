import Quick
import Nimble
@testable
import Kiosk
import Moya
import ReactiveCocoa

class FulfillmentNavigationControllerTests: QuickSpec {
    override func spec() {
        var subject: FulfillmentNavigationController!

        let token = "I'm a token"

        beforeEach {
            subject = FulfillmentNavigationController(rootViewController: UIViewController())

            subject.xAccessToken = token
        }

        afterEach {
            Provider.sharedProvider = Provider.StubbingProvider()
        }

        it("creates a loggedInProvider when the xAccessToken is set") {
            expect(subject.loggedInProvider).toNot( beNil() )
        }

        it("changes the logged-in provider to use xAccessToken") {
            let target = ArtsyAPI.Me
            let endpoint = subject.loggedInProvider!.endpointClosure(target)

            expect(endpoint.urlRequest.allHTTPHeaderFields!["X-Access-Token"]) == token
        }
        
        it("respects original endpoints closure") {
            var externalClosureInvoked = false

            let externalClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
                let endpoint = Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, {target.sampleData}), method: target.method, parameters: target.parameters)

                externalClosureInvoked = true

                return endpoint
            }

            Provider.sharedProvider = ArtsyProvider(endpointClosure: externalClosure, stubBehavior: MoyaProvider.ImmediateStubbingBehaviour, onlineSignal: RACSignal.`return`(true))


            let target = ArtsyAPI.Me
            _ = subject.loggedInProvider!.endpointClosure(target)

            expect(externalClosureInvoked) == true
        }
    }
}
