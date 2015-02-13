import Quick
import Nimble
import ReactiveCocoa
import Kiosk
import Nimble_Snapshots

class PlaceBidViewControllerConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("a bid view controller view controller", { (sharedExampleContext: SharedExampleContext) in
            var sut: PlaceBidViewController!
            var nav: FulfillmentNavigationController!

            beforeEach {
                sut = sharedExampleContext()["sut"] as PlaceBidViewController!
                nav = sharedExampleContext()["nav"] as FulfillmentNavigationController!
            }

            describe("with lot number") {
                beforeEach {
                    nav.bidDetails.saleArtwork?.lotNumber = 13
                    return
                }

                it("looks correct") {
                    sut.loadViewProgrammatically()
                    sut.cursor.stopAnimating()
                    expect(sut) == snapshot()
                }
            }

            describe("without lot number") {
                it("looks correct") {
                    sut.loadViewProgrammatically()
                    sut.cursor.stopAnimating()
                    expect(sut) == snapshot()
                }
            }
        })
    }
}

class PlaceBidViewControllerTests: QuickSpec {
    override func spec() {
        var sut: PlaceBidViewController!
        var artworkJSON: [String: AnyObject] = [
            "id":"artwork_id",
            "title" : "The Artwork Title",
            "date": "23rd Nov",
            "blurb" : "Something about the artwork",
            "price": "$33,990",
            "artist": ["id": "artist_id", "name": "Artist Name"]
        ]

        beforeEach {
            sut = PlaceBidViewController.instantiateFromStoryboard(fulfillmentStoryboard).wrapInFulfillmentNav() as PlaceBidViewController
            sut.buyersPremium = { nil }
        }

        it("looks right by default") {
            sut.loadViewProgrammatically()
            sut.cursor.stopAnimating()
            expect(sut) == snapshot()
        }

        it("looks right with a custom saleArtwork") {
            let nav = FulfillmentNavigationController(rootViewController:sut)

            let artwork = Artwork.fromJSON(artworkJSON) as Artwork
            let saleArtwork = SaleArtwork(id: "", artwork: artwork)
            nav.bidDetails = BidDetails(saleArtwork: saleArtwork, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)

            nav.loadViewProgrammatically()
            sut.loadViewProgrammatically()
            sut.cursor.stopAnimating()

            expect(sut) == snapshot()
        }

        describe("with no bids") {
            var nav: FulfillmentNavigationController!

            beforeEach {
                let customKeySubject = RACSubject()
                nav = FulfillmentNavigationController(rootViewController:sut)

                let artwork = Artwork.fromJSON(artworkJSON) as Artwork
                let saleArtwork = SaleArtwork(id: "", artwork: artwork)
                saleArtwork.minimumNextBidCents = 10000
                saleArtwork.openingBidCents = 10000
                saleArtwork.highestBidCents = nil
                saleArtwork.bidCount = 0

                nav.bidDetails = BidDetails(saleArtwork: saleArtwork, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)
            }

            itBehavesLike("a bid view controller view controller") {["sut": sut, "nav": nav]}

            describe("with a buyers premium") {
                beforeEach {
                    sut.buyersPremium = { BuyersPremium(id: "id", name: "name") }
                }

                itBehavesLike("a bid view controller view controller") {["sut": sut, "nav": nav]}
            }

            it("assigns correct text") {
                sut.loadViewProgrammatically()

                expect(sut.currentBidTitleLabel.text).to(equal("Opening Bid:"))
                expect(sut.currentBidAmountLabel.text).to(equal("$100"))
                expect(sut.nextBidAmountLabel.text).to(equal("Enter $100 or more"))
            }
        }

        describe("with bids") {
            var nav: FulfillmentNavigationController!

            beforeEach {
                let customKeySubject = RACSubject()
                nav = FulfillmentNavigationController(rootViewController:sut)

                let artwork = Artwork.fromJSON(artworkJSON) as Artwork
                let saleArtwork = SaleArtwork(id: "", artwork: artwork)
                saleArtwork.minimumNextBidCents = 25000
                saleArtwork.openingBidCents = 10000
                saleArtwork.highestBidCents = 20000
                saleArtwork.bidCount = 1

                nav.bidDetails = BidDetails(saleArtwork: saleArtwork, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)
            }

            itBehavesLike("a bid view controller view controller") {["sut": sut, "nav": nav]}

            it("assigns correct text") {
                sut.loadViewProgrammatically()

                expect(sut.currentBidTitleLabel.text).to(equal("Current Bid:"))
                expect(sut.currentBidAmountLabel.text).to(equal("$200"))
                expect(sut.nextBidAmountLabel.text).to(equal("Enter $250 or more"))
            }
        }

        it("reacts to keypad inputs with currency") {
            let customKeySubject = RACSubject()
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
            let nav = FulfillmentNavigationController(rootViewController:sut)

            let artwork = Artwork.fromJSON(artworkJSON) as Artwork
            let saleArtwork = SaleArtwork(id: "", artwork: artwork)
            saleArtwork.minimumNextBidCents = 100

            nav.bidDetails = BidDetails(saleArtwork: saleArtwork, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)

            sut.keypadSignal = customKeySubject;
            nav.loadViewProgrammatically()
            sut.loadViewProgrammatically()

            expect(sut.bidButton.enabled) == false

            customKeySubject.sendNext(200)
            expect(sut.bidButton.enabled) == true
        }

        it("passes the bid amount to the nav controller") {
            let nav = FulfillmentNavigationController(rootViewController:sut)

            let customKeySubject = RACSubject()
            sut.keypadSignal = customKeySubject;
            nav.loadViewProgrammatically()
            sut.loadViewProgrammatically()

            customKeySubject.sendNext(3);
            customKeySubject.sendNext(3);

            expect(nav.bidDetails.bidAmountCents) == 3300
        }
    }
}
