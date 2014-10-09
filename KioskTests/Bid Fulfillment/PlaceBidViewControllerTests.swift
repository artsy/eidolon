import Quick
import Nimble

class PlaceBidViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut = PlaceBidViewController.instantiateFromStoryboard()
            expect(sut).to(haveValidSnapshot(named:"default"))
        }

        it("looks right with a custom saleArtwork") {
            let sut = PlaceBidViewController.instantiateFromStoryboard()
            let nav = FulfillmentNavigationController(rootViewController:sut)

            let artwork = Artwork(id: "", dateString: "23rd Nov", title: "The Artwork Title", name: "Name of Artwork", blurb: "Something about the artwork", price: "$33,990", date: "Some date?")
            let saleArtwork = SaleArtwork(id: "", artwork: artwork)
            nav!.bidDetails = BidDetails(saleArtwork: saleArtwork, bidderID: nil, bidderPIN: nil, bidAmountCents: nil)

            nav!.loadViewProgrammatically()
            sut.loadViewProgrammatically()

            expect(sut).to(haveValidSnapshot(named:"with artwork"))
        }

        describe("with no bids") {
            var sut: PlaceBidViewController?
            beforeEach {
                let customKeySubject = RACSubject()
                sut = PlaceBidViewController.instantiateFromStoryboard()
                let nav = FulfillmentNavigationController(rootViewController:sut!)

                let artwork = Artwork(id: "", dateString: "23rd Nov", title: "The Artwork Title", name: "Name of Artwork", blurb: "Something about the artwork", price: "$33,990", date: "Some date?")
                let saleArtwork = SaleArtwork(id: "", artwork: artwork)
                saleArtwork.minimumNextBidCents = 10000
                saleArtwork.openingBidCents = 10000
                saleArtwork.highestBidCents = nil
                saleArtwork.bidCount = 0

                nav!.bidDetails = BidDetails(saleArtwork: saleArtwork, bidderID: nil, bidderPIN: nil, bidAmountCents: nil)
                nav!.loadViewProgrammatically()
                sut!.loadViewProgrammatically()
            }

            it("looks correct") {
                expect(sut!).to(haveValidSnapshot(named: "no bids"))
                return
            }

            it("assigns correct text") {
                expect(sut!.currentBidTitleLabel.text).to(equal("Opening Bid:"))
                expect(sut!.currentBidAmountLabel.text).to(equal("$100"))
                expect(sut!.nextBidAmountLabel.text).to(equal("Enter $100 or more"))
            }
        }

        describe("with bids") {
            var sut: PlaceBidViewController?
            beforeEach {
                let customKeySubject = RACSubject()
                sut = PlaceBidViewController.instantiateFromStoryboard()
                let nav = FulfillmentNavigationController(rootViewController:sut!)

                let artwork = Artwork(id: "", dateString: "23rd Nov", title: "The Artwork Title", name: "Name of Artwork", blurb: "Something about the artwork", price: "$33,990", date: "Some date?")
                let saleArtwork = SaleArtwork(id: "", artwork: artwork)
                saleArtwork.minimumNextBidCents = 25000
                saleArtwork.openingBidCents = 10000
                saleArtwork.highestBidCents = 20000
                saleArtwork.bidCount = 1

                nav!.bidDetails = BidDetails(saleArtwork: saleArtwork, bidderID: nil, bidderPIN: nil, bidAmountCents: nil)
                nav!.loadViewProgrammatically()
                sut!.loadViewProgrammatically()
            }

            it("looks correct") {
                expect(sut!).to(haveValidSnapshot(named: "with bids"))
                return
            }

            it("assigns correct text") {
                expect(sut!.currentBidTitleLabel.text).to(equal("Current Bid:"))
                expect(sut!.currentBidAmountLabel.text).to(equal("$200"))
                expect(sut!.nextBidAmountLabel.text).to(equal("Enter $250 or more"))
            }
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

        it("bid button is only enabled when bid is greater than min next bid") {
            let customKeySubject = RACSubject()
            let sut = PlaceBidViewController.instantiateFromStoryboard()
            let nav = FulfillmentNavigationController(rootViewController:sut)

            let artwork = Artwork(id: "", dateString: "23rd Nov", title: "The Artwork Title", name: "Name of Artwork", blurb: "Something about the artwork", price: "$33,990", date: "Some date?")
            let saleArtwork = SaleArtwork(id: "", artwork: artwork)
            saleArtwork.minimumNextBidCents = 100

            nav!.bidDetails = BidDetails(saleArtwork: saleArtwork, bidderID: nil, bidderPIN: nil, bidAmountCents: nil)

            sut.keypadSignal = customKeySubject;
            nav!.loadViewProgrammatically()
            sut.loadViewProgrammatically()

            expect(sut.bidButton.enabled) == false

            customKeySubject.sendNext(200);
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
