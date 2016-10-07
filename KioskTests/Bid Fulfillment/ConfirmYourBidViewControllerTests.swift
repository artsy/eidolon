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
            let keypadSubject = Variable("")
            subject.number = keypadSubject.asObservable()

            subject.loadViewProgrammatically()
            keypadSubject.value = "3"

            expect(subject.numberAmountTextField.text) == "3"
        }

        pending("changes enter button to enabled") {
            let keypadSubject = Variable("")
            subject.number = keypadSubject.asObservable()

            subject.loadViewProgrammatically()

            expect(subject.enterButton.isEnabled) == false
            keypadSubject.value = "3"
            expect(subject.enterButton.isEnabled) == true
        }

    }
}
