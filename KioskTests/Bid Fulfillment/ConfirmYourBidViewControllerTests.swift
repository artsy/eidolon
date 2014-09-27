import Quick
import Nimble

class ConfirmYourBidViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = ConfirmYourBidViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot())
        }

        it("shows keypad buttons") {
            let sut = ConfirmYourBidViewController.instantiateFromStoryboard()
            let keypadSubject = RACSubject()
            sut.keypadSignal = keypadSubject

            sut.loadViewProgrammatically()

            keypadSubject.sendNext(3)

            expect(sut.numberAmountTextField.text) == "3"
            expect(sut.enterButton.enabled) == true
        }

        it("changes enter button to enabled") {
            let sut = ConfirmYourBidViewController.instantiateFromStoryboard()
            let keypadSubject = RACSubject()
            sut.keypadSignal = keypadSubject

            sut.loadViewProgrammatically()

            expect(sut.enterButton.enabled) == false
            keypadSubject.sendNext(3)
            expect(sut.enterButton.enabled) == true
        }

    }
}
