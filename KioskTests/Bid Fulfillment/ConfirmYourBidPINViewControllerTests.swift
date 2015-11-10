import Quick
import Nimble
@testable
import Kiosk
import Moya
import RxSwift
import Nimble_Snapshots

class ConfirmYourBidPINViewControllerTests: QuickSpec {
    override func spec() {

        afterEach {
            Provider.sharedProvider = Provider.StubbingProvider()
        }

        it("looks right by default") {
            let subject = testConfirmYourBidPINViewController()
            subject.loadViewProgrammatically()
            expect(subject) == snapshot()
        }

        it("reacts to keypad inputs with the string") {
            let customKeySubject = RACSubject()
            let subject = testConfirmYourBidPINViewController()
            subject.pinSignal = customKeySubject
            subject.loadViewProgrammatically()

            customKeySubject.sendNext("2344");
            expect(subject.pinTextField.text) == "2344"
        }

        it("reacts to keypad inputs with the string") {
            let customKeySubject = RACSubject()

            let subject = testConfirmYourBidPINViewController()
            subject.pinSignal = customKeySubject

            subject.loadViewProgrammatically()

            customKeySubject.sendNext("2");
            expect(subject.pinTextField.text) == "2"
        }

        it("reacts to keypad inputs with the string") {
            let customKeySubject = RACSubject()

            let subject = testConfirmYourBidPINViewController()
            subject.pinSignal = customKeySubject;

            subject.loadViewProgrammatically()

            customKeySubject.sendNext("222");
            expect(subject.pinTextField.text) == "222"
        }

        it("adds the correct auth params to a PIN'd request") {
            let auctionID = "AUCTION"
            let pin = "PIN"
            let number = "NUMBER"
            let subject = ConfirmYourBidPINViewController()
            let nav = FulfillmentNavigationController(rootViewController:subject)
            nav.auctionID = auctionID

            let provider: ReactiveCocoaMoyaProvider<ArtsyAPI> = subject.providerForPIN(pin, number: number)
            let endpoint = provider.endpointClosure(ArtsyAPI.Me)
            var request: NSURLRequest!
            provider.requestClosure(endpoint) { request = $0 }

            let address = request.URL!.absoluteString
            expect(address).to( contain(auctionID) )
            expect(address).to( contain(pin) )
            expect(address).to( contain(number) )
        }

        it("respects original endpoints closure") {
            var externalClosureInvoked = false

            let externalClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
                let endpoint = Endpoint<ArtsyAPI>(URL: url(target), sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)

                externalClosureInvoked = true

                return endpoint
            }

            Provider.sharedProvider = ArtsyProvider(endpointClosure: externalClosure, stubClosure: MoyaProvider<ArtsyAPI>.ImmediatelyStub, onlineSignal: RACSignal.`return`(true))


            let subject = ConfirmYourBidPINViewController()
            let nav = FulfillmentNavigationController(rootViewController: subject)
            nav.auctionID = "AUCTION"
            let provider: ReactiveCocoaMoyaProvider<ArtsyAPI> = subject.providerForPIN("12341234", number: "1234")

            waitUntil{ done -> Void in
                provider.request(.Me).subscribeCompleted {
                    done()
                }
            }

            expect(externalClosureInvoked) == true
        }
    }
}

func testConfirmYourBidPINViewController() -> ConfirmYourBidPINViewController {
    return ConfirmYourBidPINViewController.instantiateFromStoryboard(fulfillmentStoryboard).wrapInFulfillmentNav() as! ConfirmYourBidPINViewController
}
