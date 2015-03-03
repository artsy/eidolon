import Quick
import Nimble
import ReactiveCocoa
import Kiosk
import Nimble_Snapshots

class PlaceBidViewControllerConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("a bid view controller view controller", { (sharedExampleContext: SharedExampleContext) in
            var subject: PlaceBidViewController!
            var nav: FulfillmentNavigationController!

            beforeEach {
                subject = sharedExampleContext()["subject"] as PlaceBidViewController!
                nav = sharedExampleContext()["nav"] as FulfillmentNavigationController!
            }

            describe("with lot number") {
                beforeEach {
                    nav.bidDetails.saleArtwork?.lotNumber = 13
                    return
                }

                it("looks correct") {
                    subject.loadViewProgrammatically()
                    subject.cursor.stopAnimating()
                    expect(subject) == snapshot()
                }
            }

            describe("without lot number") {
                it("looks correct") {
                    subject.loadViewProgrammatically()
                    subject.cursor.stopAnimating()
                    expect(subject) == snapshot()
                }
            }
        })
    }
}

class PlaceBidViewControllerTests: QuickSpec {
    override func spec() {
        var subject: PlaceBidViewController!
        var artworkJSON: [String: AnyObject] = [
            "id":"artwork_id",
            "title" : "The Artwork Title",
            "date": "23rd Nov",
            "blurb" : "Something about the artwork",
            "price": "$33,990",
            "artist": ["id": "artist_id", "name": "Artist Name"]
        ]

        beforeEach {
            subject = PlaceBidViewController.instantiateFromStoryboard(fulfillmentStoryboard).wrapInFulfillmentNav() as PlaceBidViewController
            subject.buyersPremium = { nil }
        }

        it("looks right by default") {
            subject.loadViewProgrammatically()
            subject.cursor.stopAnimating()
            expect(subject) == snapshot()
        }

        it("looks right with a custom saleArtwork") {
            let nav = FulfillmentNavigationController(rootViewController:subject)

            let artwork = Artwork.fromJSON(artworkJSON) as Artwork
            let saleArtwork = SaleArtwork(id: "", artwork: artwork)
            nav.bidDetails = BidDetails(saleArtwork: saleArtwork, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)

            nav.loadViewProgrammatically()
            subject.loadViewProgrammatically()
            subject.cursor.stopAnimating()

            expect(subject) == snapshot()
        }

        describe("with no bids") {
            var nav: FulfillmentNavigationController!

            beforeEach {
                let customKeySubject = RACSubject()
                nav = FulfillmentNavigationController(rootViewController:subject)

                let artwork = Artwork.fromJSON(artworkJSON) as Artwork
                let saleArtwork = SaleArtwork(id: "", artwork: artwork)
                saleArtwork.minimumNextBidCents = 10000
                saleArtwork.openingBidCents = 10000
                saleArtwork.highestBidCents = nil
                saleArtwork.bidCount = 0

                nav.bidDetails = BidDetails(saleArtwork: saleArtwork, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)
            }

            itBehavesLike("a bid view controller view controller") {["subject": subject, "nav": nav]}

            describe("with a buyers premium") {
                beforeEach {
                    subject.buyersPremium = { BuyersPremium(id: "id", name: "name") }
                }

                itBehavesLike("a bid view controller view controller") {["subject": subject, "nav": nav]}
            }

            it("assigns correct text") {
                subject.loadViewProgrammatically()

                expect(subject.currentBidTitleLabel.text).to(equal("Opening Bid:"))
                expect(subject.currentBidAmountLabel.text).to(equal("$100"))
                expect(subject.nextBidAmountLabel.text).to(equal("Enter $100 or more"))
            }
        }

        describe("with bids") {
            var nav: FulfillmentNavigationController!

            beforeEach {
                let customKeySubject = RACSubject()
                nav = FulfillmentNavigationController(rootViewController:subject)

                let artwork = Artwork.fromJSON(artworkJSON) as Artwork
                let saleArtwork = SaleArtwork(id: "", artwork: artwork)
                saleArtwork.minimumNextBidCents = 25000
                saleArtwork.openingBidCents = 10000
                saleArtwork.highestBidCents = 20000
                saleArtwork.bidCount = 1

                nav.bidDetails = BidDetails(saleArtwork: saleArtwork, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)
            }

            itBehavesLike("a bid view controller view controller") {["subject": subject, "nav": nav]}

            it("assigns correct text") {
                subject.loadViewProgrammatically()

                expect(subject.currentBidTitleLabel.text).to(equal("Current Bid:"))
                expect(subject.currentBidAmountLabel.text).to(equal("$200"))
                expect(subject.nextBidAmountLabel.text).to(equal("Enter $250 or more"))
            }
        }

        it("reacts to keypad inputs with currency") {
            let customKeySubject = RACSubject()
            subject.bidDollarSignal = customKeySubject;
            subject.loadViewProgrammatically()

            customKeySubject.sendNext(2);
            expect(subject.bidAmountTextField.text) == "2"

            customKeySubject.sendNext(3);
            expect(subject.bidAmountTextField.text) == "23"

            customKeySubject.sendNext(4);
            customKeySubject.sendNext(4);
            expect(subject.bidAmountTextField.text) == "2,344"
        }

        it("bid button is only enabled when bid is greater than min next bid") {
            let customKeySubject = RACSubject()
            let nav = FulfillmentNavigationController(rootViewController:subject)

            let artwork = Artwork.fromJSON(artworkJSON) as Artwork
            let saleArtwork = SaleArtwork(id: "", artwork: artwork)
            saleArtwork.minimumNextBidCents = 100

            nav.bidDetails = BidDetails(saleArtwork: saleArtwork, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)

            subject.bidDollarSignal = customKeySubject;
            nav.loadViewProgrammatically()
            subject.loadViewProgrammatically()

            expect(subject.bidButton.enabled) == false

            customKeySubject.sendNext(200)
            expect(subject.bidButton.enabled) == true
        }

        it("passes the bid amount to the nav controller") {
            let nav = FulfillmentNavigationController(rootViewController:subject)

            let customKeySubject = RACSubject()
            subject.bidDollarSignal = customKeySubject;
            nav.loadViewProgrammatically()
            subject.loadViewProgrammatically()

            customKeySubject.sendNext(3);
            customKeySubject.sendNext(3);

            expect(nav.bidDetails.bidAmountCents) == 3300
        }
    }
}
