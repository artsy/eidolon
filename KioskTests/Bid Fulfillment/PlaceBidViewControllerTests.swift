import Quick
import Nimble

class PlaceBidViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = PlaceBidViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot(named:"default"))
        }

        it("looks right with a custom saleArtwork") {
            let sut = ConfirmYourBidEnterYourEmailViewController.instantiateFromStoryboard()
            let nav = FulfillmentNavigationController(rootViewController:sut)

            let artwork = Artwork(id: "", dateString: "23rd Nov", title: "The Artwork Title", name: "Name of Artwork", blurb: "Something about the artwork", price: "$33,990", date: "Some date?")
            let saleArtwork = SaleArtwork(id: "", artwork: artwork)
            nav!.bidDetails = BidDetails(saleArtwork: saleArtwork, bidderID: nil, bidderPIN: nil, bidAmountCents: nil)

            nav!.loadViewProgrammatically()
            sut.loadViewProgrammatically()

            expect(nav!).to(haveValidSnapshot(named:"with artwork"))
        }

        it("reacts to keypad inputs with currency") {
            let customKeySubject = RACSubject()
            let sut = PlaceBidViewController.instantiateFromStoryboard()
            sut.keypadSignal = customKeySubject;
            sut.loadViewProgrammatically()

            customKeySubject.sendNext(2);
            expect(sut.bidAmountTextField.text) == "2"

            customKeySubject.sendNext(3);
            expect(sut.bidAmountTextField.text) == "23"

            customKeySubject.sendNext(4);
            customKeySubject.sendNext(4);
            expect(sut.bidAmountTextField.text) == "2,344"
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

        it("passes the bid amount to the nav controller") {

            let sut = PlaceBidViewController.instantiateFromStoryboard()
            let nav = FulfillmentNavigationController(rootViewController:sut)

            let customKeySubject = RACSubject()
            sut.keypadSignal = customKeySubject;
            nav!.loadViewProgrammatically()
            sut.loadViewProgrammatically()

            customKeySubject.sendNext(3);
            customKeySubject.sendNext(3);

            expect(nav!.bidDetails.bidAmountCents) == 3300
        }

    }
}
