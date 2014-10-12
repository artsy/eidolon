import Quick
import Nimble

class ConfirmYourBidViewControllerTests: QuickSpec {
    override func spec() {
        var sut: ConfirmYourBidViewController!
        beforeEach {
            sut = ConfirmYourBidViewController.instantiateFromStoryboard()
        }

        pending("looks right by default") {
            sut.loadViewProgrammatically()
            expect(sut).to(haveValidSnapshot(named:"default"))
        }

        it("shows keypad buttons") {
            let keypadSubject = RACSubject()
            sut.keypadSignal = keypadSubject

            sut.loadViewProgrammatically()
            sut.cursor.stopAnimating()

            keypadSubject.sendNext(3)

            expect(sut.numberAmountTextField.text) == "3"
            expect(sut.enterButton.enabled) == true
        }

        it("changes enter button to enabled") {
            let keypadSubject = RACSubject()
            sut.keypadSignal = keypadSubject

            sut.loadViewProgrammatically()
            sut.cursor.stopAnimating()

            expect(sut.enterButton.enabled) == false
            keypadSubject.sendNext(3)
            expect(sut.enterButton.enabled) == true
        }

    }
}
