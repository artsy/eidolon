import Quick
import Nimble
import Nimble_Snapshots
import Kiosk

class ConfirmYourBidViewControllerTests: QuickSpec {
    override func spec() {
        var sut: ConfirmYourBidViewController!
        var nav: FulfillmentNavigationController!

        beforeEach {
            sut = ConfirmYourBidViewController.instantiateFromStoryboard()
            nav = FulfillmentNavigationController(rootViewController:sut)
        }

        pending("looks right by default") {
            sut.loadViewProgrammatically()
            expect(sut).to(haveValidSnapshot(named:"default"))
        }

        it("shows keypad buttons") {
            let keypadSubject = RACSubject()
            sut.keypadSignal = keypadSubject

            sut.loadViewProgrammatically()
            keypadSubject.sendNext(3)

            expect(sut.numberAmountTextField.text) == "3"
        }

        pending("changes enter button to enabled") {
            let keypadSubject = RACSubject()
            sut.keypadSignal = keypadSubject

            sut.loadViewProgrammatically()

            expect(sut.enterButton.enabled) == false
            keypadSubject.sendNext(3)
            expect(sut.enterButton.enabled) == true
        }

    }
}
