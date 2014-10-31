import Quick
import Nimble

class ConfirmYourBidPINViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = ConfirmYourBidPINViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot(named:"default"))
        }

        it("reacts to keypad inputs with the string") {
            let customKeySubject = RACSubject()
            let sut = ConfirmYourBidPINViewController.instantiateFromStoryboard()
            sut.keypadSignal = customKeySubject;
            sut.loadViewProgrammatically()

            customKeySubject.sendNext(2);
            expect(sut.pinTextField.text) == "2"

            customKeySubject.sendNext(3);
            expect(sut.pinTextField.text) == "23"

            customKeySubject.sendNext(4);
            customKeySubject.sendNext(4);
            expect(sut.pinTextField.text) == "2344"
        }

        it("reacts to keypad inputs with the string") {
            let customKeySubject = RACSubject()
            let deleteSubject = RACSubject()

            let sut = ConfirmYourBidPINViewController.instantiateFromStoryboard()
            sut.keypadSignal = customKeySubject;
            sut.deleteSignal = deleteSubject

            sut.loadViewProgrammatically()

            customKeySubject.sendNext(2);
            expect(sut.pinTextField.text) == "2"

            deleteSubject.sendNext(0);
            expect(sut.pinTextField.text) == ""
        }

        it("reacts to keypad inputs with the string") {
            let customKeySubject = RACSubject()
            let clearSubject = RACSubject()

            let sut = ConfirmYourBidPINViewController.instantiateFromStoryboard()
            sut.keypadSignal = customKeySubject;
            sut.clearSignal = clearSubject

            sut.loadViewProgrammatically()

            customKeySubject.sendNext(2);
            customKeySubject.sendNext(2);
            customKeySubject.sendNext(2);
            expect(sut.pinTextField.text) == "222"

            clearSubject.sendNext(0);
            expect(sut.pinTextField.text) == ""
        }

        it("adds the correct auth params to a PIN'd request") {
            let auctionID = "AUCTION"
            let pin = "PIN"
            let number = "NUMBER"
            let sut = ConfirmYourBidPINViewController()
            let nav = FulfillmentNavigationController(rootViewController:sut)
            nav?.auctionID = auctionID

            let provider: ReactiveMoyaProvider<ArtsyAPI> = sut.providerForPIN(pin, number: number)
            let endpoint = provider.endpointsClosure(ArtsyAPI.Me, method: Moya.Method.GET, parameters:["":""])
            let request = provider.endpointResolver(endpoint: endpoint)

            let address = request.URL.absoluteString!
            expect(address).to( contain(auctionID) )
            expect(address).to( contain(pin) )
            expect(address).to( contain(number) )

        }

    }
}
