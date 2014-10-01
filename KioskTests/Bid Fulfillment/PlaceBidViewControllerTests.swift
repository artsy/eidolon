import Quick
import Nimble

class PlaceBidViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = PlaceBidViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot(named:"default"))
        }

        it("reacts to keypad inputs with currency") {
            let customKeySubject = RACSubject()
            let sut = PlaceBidViewController.instantiateFromStoryboard()
            sut.keypadSignal = customKeySubject;
            sut.loadViewProgrammatically()

            customKeySubject.sendNext(2);
            expect(sut.bidAmountTextField.text) == "$2"

            customKeySubject.sendNext(3);
            expect(sut.bidAmountTextField.text) == "$23"

            customKeySubject.sendNext(4);
            customKeySubject.sendNext(4);
            expect(sut.bidAmountTextField.text) == "$2,344"
        }

        it("bid button is only enabled when there's an input") {
            let customKeySubject = RACSubject()
            let sut = PlaceBidViewController.instantiateFromStoryboard()
            sut.keypadSignal = customKeySubject;
            sut.loadViewProgrammatically()

            expect(sut.bidButton.enabled) == false

            customKeySubject.sendNext(2);
            expect(sut.bidButton.enabled) == true
        }



        it("passes a bid object to the ConfirmYour Bid VC, during segue") {

            let sut = PlaceBidViewController.instantiateFromStoryboard()
            let confirmVC = ConfirmYourBidViewController.instantiateFromStoryboard()
            let segue = UIStoryboardSegue(identifier: SegueIdentifier.ConfirmBid.rawValue, source: sut, destination: confirmVC, performHandler: { () -> Void in })

            sut.prepareForSegue(segue, sender: sut)
            expect(confirmVC.bid?).to(beAnInstanceOf(Bid.self))

        }

    }
}
