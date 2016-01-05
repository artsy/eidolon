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
    }
}

func testConfirmYourBidPINViewController() -> ConfirmYourBidPINViewController {
    let controller = ConfirmYourBidPINViewController.instantiateFromStoryboard(fulfillmentStoryboard).wrapInFulfillmentNav() as! ConfirmYourBidPINViewController
    controller.provider = Networking.newStubbingNetworking()
    return controller
}
