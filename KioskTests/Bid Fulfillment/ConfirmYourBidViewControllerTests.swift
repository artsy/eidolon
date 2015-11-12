import Quick
import Nimble
import Nimble_Snapshots
import RxSwift
@testable
import Kiosk

class ConfirmYourBidViewControllerTests: QuickSpec {
    override func spec() {
        var subject: ConfirmYourBidViewController!

        beforeEach {
            subject = ConfirmYourBidViewController.instantiateFromStoryboard(fulfillmentStoryboard).wrapInFulfillmentNav() as! ConfirmYourBidViewController
        }

        pending("looks right by default") {
            subject.loadViewProgrammatically()
            expect(subject) == snapshot("default")
        }

        it("shows keypad buttons") {
            let keypadSubject = RACSubject()
            subject.numberSignal = keypadSubject

            subject.loadViewProgrammatically()
            keypadSubject.sendNext("3")

            expect(subject.numberAmountTextField.text) == "3"
        }

        pending("changes enter button to enabled") {
            let keypadSubject = RACSubject()
            subject.numberSignal = keypadSubject

            subject.loadViewProgrammatically()

            expect(subject.enterButton.enabled) == false
            keypadSubject.sendNext(3)
            expect(subject.enterButton.enabled) == true
        }

    }
}
