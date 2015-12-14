import Quick
import Nimble
@testable
import Kiosk
import Moya
import RxSwift
import Nimble_Snapshots

class ConfirmYourBidPINViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let subject = testConfirmYourBidPINViewController()
            subject.loadViewProgrammatically()
            expect(subject) == snapshot()
        }

        it("reacts to keypad inputs with the string") {
            let customKeySubject = PublishSubject<String>()
            let subject = testConfirmYourBidPINViewController()
            subject.pin = customKeySubject.asObservable()
            subject.loadViewProgrammatically()

            customKeySubject.onNext("2344");
            expect(subject.pinTextField.text) == "2344"
        }

        it("reacts to keypad inputs with the string") {
            let customKeySubject = PublishSubject<String>()

            let subject = testConfirmYourBidPINViewController()
            subject.pin = customKeySubject

            subject.loadViewProgrammatically()

            customKeySubject.onNext("2");
            expect(subject.pinTextField.text) == "2"
        }

        it("reacts to keypad inputs with the string") {
            let customKeySubject = PublishSubject<String>()

            let subject = testConfirmYourBidPINViewController()
            subject.pin = customKeySubject;

            subject.loadViewProgrammatically()

            customKeySubject.onNext("222");
            expect(subject.pinTextField.text) == "222"
        }

        it("adds the correct auth params to a PIN'd request") {
            let auctionID = "AUCTION"
            let pin = "PIN"
            let number = "NUMBER"
            let subject = ConfirmYourBidPINViewController()
            let nav = FulfillmentNavigationController(rootViewController:subject)
            nav.auctionID = auctionID

            let provider = subject.providerForPIN(pin, number: number)
            let endpoint = provider.provider.endpointClosure(ArtsyAuthenticatedAPI.Me)
            var request: NSURLRequest!
            provider.provider.requestClosure(endpoint) { request = $0 }

            let address = request.URL!.absoluteString
            expect(address).to( contain(auctionID) )
            expect(address).to( contain(pin) )
            expect(address).to( contain(number) )
        }
    }
}

func testConfirmYourBidPINViewController() -> ConfirmYourBidPINViewController {
    let controller = ConfirmYourBidPINViewController.instantiateFromStoryboard(fulfillmentStoryboard).wrapInFulfillmentNav() as! ConfirmYourBidPINViewController
    controller.provider = Networking.newStubbingNetworking()
    return controller
}
