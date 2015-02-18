import Quick
import Nimble
import Kiosk
import Moya
import ReactiveCocoa
import Nimble_Snapshots

class ConfirmYourBidPINViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let subject = testConfirmYourBidPINViewController()
            expect(subject).to(haveValidSnapshot())
        }

        it("reacts to keypad inputs with the string") {
            let customKeySubject = RACSubject()
            let subject = testConfirmYourBidPINViewController()
            subject.keypadSignal = customKeySubject;
            subject.loadViewProgrammatically()

            customKeySubject.sendNext(2);
            expect(subject.pinTextField.text) == "2"

            customKeySubject.sendNext(3);
            expect(subject.pinTextField.text) == "23"

            customKeySubject.sendNext(4);
            customKeySubject.sendNext(4);
            expect(subject.pinTextField.text) == "2344"
        }

        it("reacts to keypad inputs with the string") {
            let customKeySubject = RACSubject()
            let deleteSubject = RACSubject()

            let subject = testConfirmYourBidPINViewController()
            subject.keypadSignal = customKeySubject;
            subject.deleteSignal = deleteSubject

            subject.loadViewProgrammatically()

            customKeySubject.sendNext(2);
            expect(subject.pinTextField.text) == "2"

            deleteSubject.sendNext(0);
            expect(subject.pinTextField.text) == ""
        }

        it("reacts to keypad inputs with the string") {
            let customKeySubject = RACSubject()
            let clearSubject = RACSubject()

            let subject = testConfirmYourBidPINViewController()
            subject.keypadSignal = customKeySubject;
            subject.clearSignal = clearSubject

            subject.loadViewProgrammatically()

            customKeySubject.sendNext(2);
            customKeySubject.sendNext(2);
            customKeySubject.sendNext(2);
            expect(subject.pinTextField.text) == "222"

            clearSubject.sendNext(0);
            expect(subject.pinTextField.text) == ""
        }

        it("adds the correct auth params to a PIN'd request") {
            let auctionID = "AUCTION"
            let pin = "PIN"
            let number = "NUMBER"
            let subject = ConfirmYourBidPINViewController()
            let nav = FulfillmentNavigationController(rootViewController:subject)
            nav.auctionID = auctionID

            let provider: ReactiveMoyaProvider<ArtsyAPI> = subject.providerForPIN(pin, number: number)
            let endpoint = provider.endpointsClosure(ArtsyAPI.Me, method: Moya.Method.GET, parameters:["":""])
            let request = provider.endpointResolver(endpoint: endpoint)

            let address = request.URL.absoluteString!
            expect(address).to( contain(auctionID) )
            expect(address).to( contain(pin) )
            expect(address).to( contain(number) )

        }

    }
}

func testConfirmYourBidPINViewController() -> ConfirmYourBidPINViewController {
    return ConfirmYourBidPINViewController.instantiateFromStoryboard(fulfillmentStoryboard).wrapInFulfillmentNav() as ConfirmYourBidPINViewController
}
