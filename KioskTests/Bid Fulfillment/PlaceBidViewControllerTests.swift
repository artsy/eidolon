import Quick
import Nimble
import Kiosk

class PlaceBidViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = PlaceBidViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot())
        }

        it("reacts to keypad inputs with currency") {
            let customKeySubject = RACSubject()
            let sut = PlaceBidViewController.instantiateFromStoryboard()
            sut.keypadSignal = customKeySubject;

            sut.beginAppearanceTransition(true, animated: false)
            sut.endAppearanceTransition()

            customKeySubject.sendNext(2);
            expect(sut.bidAmountTextField.text) == "$2"

            customKeySubject.sendNext(3);
            expect(sut.bidAmountTextField.text) == "$23"

            customKeySubject.sendNext(4);
            customKeySubject.sendNext(4);
            expect(sut.bidAmountTextField.text) == "$2,344"
        }

    }
}
