import Quick
import Nimble

class ConfirmYourBidViewControllerTests: QuickSpec {
    override func spec() {
        var sut: ConfirmYourBidViewController?
        beforeEach {
            sut = ConfirmYourBidViewController.instantiateFromStoryboard()
            sut.cursor.stopAnimating()
        }

        it("looks right by default") {
            expect(sut!).to(haveValidSnapshot(named:"default"))
        }

        it("shows keypad buttons") {
            let keypadSubject = RACSubject()
            sut!.keypadSignal = keypadSubject

            sut!.loadViewProgrammatically()

            keypadSubject.sendNext(3)

            expect(sut!.numberAmountTextField.text) == "3"
            expect(sut!.enterButton.enabled) == true
        }

        it("changes enter button to enabled") {
            let keypadSubject = RACSubject()
            sut!.keypadSignal = keypadSubject

            sut!.loadViewProgrammatically()

            expect(sut!.enterButton.enabled) == false
            keypadSubject.sendNext(3)
            expect(sut!.enterButton.enabled) == true
        }

    }
}
