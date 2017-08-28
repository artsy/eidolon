import Quick
import Nimble
import RxNimble
import RxSwift
@testable
import Kiosk
import Nimble_Snapshots

class PlaceBidViewControllerConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("a bid view controller view controller") { (sharedExampleContext: @escaping SharedExampleContext) in
            var subject: PlaceBidViewController!
            var nav: FulfillmentNavigationController!

            beforeEach {
                subject = sharedExampleContext()["subject"] as! PlaceBidViewController!
                nav = sharedExampleContext()["nav"] as! FulfillmentNavigationController!
            }

            describe("with lot number") {
                beforeEach {
                    nav.bidDetails.saleArtwork?.lotLabel = "13"
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
        }
    }
}

class PlaceBidViewControllerTests: QuickSpec {
    override func spec() {
        var subject: PlaceBidViewController!
        let artworkJSON: [String: Any] = [
            "id":"artwork_id" as AnyObject,
            "title" : "The Artwork Title" as AnyObject,
            "date": "23rd Nov" as AnyObject,
            "blurb" : "Something about the artwork" as AnyObject,
            "price": "$33,990" as AnyObject,
            "artist": ["id": "artist_id", "name": "Artist Name"]
        ]

        beforeEach {
            subject = PlaceBidViewController.instantiateFromStoryboard(fulfillmentStoryboard).wrapInFulfillmentNav() as! PlaceBidViewController
            subject.buyersPremium = { nil }
        }

        it("looks right by default") {
            subject.loadViewProgrammatically()
            subject.cursor.stopAnimating()
            expect(subject) == snapshot()
        }

        it("looks right with a custom saleArtwork") {
            let nav = FulfillmentNavigationController(rootViewController: subject)
            nav.auctionID = testAuctionID

            let artwork = Artwork.fromJSON(artworkJSON)
            let saleArtwork = SaleArtwork(id: "", artwork: artwork, currencySymbol: "£")
            saleArtwork.minimumNextBidCents = 10000
            nav.bidDetails = BidDetails(saleArtwork: saleArtwork, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil, auctionID: testAuctionID)

            nav.loadViewProgrammatically()
            subject.loadViewProgrammatically()
            subject.cursor.stopAnimating()

            expect(subject) == snapshot()
        }

        describe("with no bids") {
            var nav: FulfillmentNavigationController!

            beforeEach {
                nav = FulfillmentNavigationController(rootViewController:subject)
                nav.auctionID = testAuctionID

                let artwork = Artwork.fromJSON(artworkJSON)
                let saleArtwork = SaleArtwork(id: "", artwork: artwork, currencySymbol: "£")
                saleArtwork.minimumNextBidCents = 10000
                saleArtwork.openingBidCents = 10000
                saleArtwork.highestBidCents = nil
                saleArtwork.bidCount = 0

                nav.bidDetails = BidDetails(saleArtwork: saleArtwork, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil, auctionID: testAuctionID)
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
                expect(subject.currentBidAmountLabel.text).to(equal("£100"))
                expect(subject.nextBidAmountLabel.text).to(equal("Enter £100 or more"))
            }
        }

        describe("with bids") {
            var nav: FulfillmentNavigationController!

            beforeEach {
                nav = FulfillmentNavigationController(rootViewController:subject)
                nav.auctionID = testAuctionID

                let artwork = Artwork.fromJSON(artworkJSON)
                let saleArtwork = SaleArtwork(id: "", artwork: artwork, currencySymbol: "£")
                saleArtwork.minimumNextBidCents = 25000
                saleArtwork.openingBidCents = 10000
                saleArtwork.highestBidCents = 20000
                saleArtwork.bidCount = 1

                nav.bidDetails = BidDetails(saleArtwork: saleArtwork, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil, auctionID: testAuctionID)
            }

            itBehavesLike("a bid view controller view controller") {["subject": subject, "nav": nav]}

            it("assigns correct text") {
                subject.loadViewProgrammatically()

                expect(subject.currentBidTitleLabel.text).to(equal("Current Bid:"))
                expect(subject.currentBidAmountLabel.text).to(equal("£200"))
                expect(subject.nextBidAmountLabel.text).to(equal("Enter £250 or more"))
            }
        }

        it("reacts to keypad inputs with currency") {
            let customKeySubject = PublishSubject<Currency>()
            subject.bidDollars = customKeySubject.asObservable()
            subject.loadViewProgrammatically()

            customKeySubject.onNext(2344);
            expect(subject.bidAmountTextField.text) == "2,344"
        }

        it("bid button is only enabled when bid is greater than min next bid") {
            let customKeySubject = PublishSubject<Currency>()
            let nav = FulfillmentNavigationController(rootViewController:subject)
            nav.auctionID = testAuctionID

            let artwork = Artwork.fromJSON(artworkJSON)
            let saleArtwork = SaleArtwork(id: "", artwork: artwork, currencySymbol: "£")
            saleArtwork.minimumNextBidCents = 100

            nav.bidDetails = BidDetails(saleArtwork: saleArtwork, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil, auctionID: testAuctionID)

            subject.bidDollars = customKeySubject.asObservable()
            nav.loadViewProgrammatically()
            subject.loadViewProgrammatically()

            expect(subject.bidButton.isEnabled) == false

            customKeySubject.onNext(200)
            expect(subject.bidButton.isEnabled) == true
        }

        it("passes the bid amount to the nav controller") {
            let nav = FulfillmentNavigationController(rootViewController:subject)
            nav.auctionID = testAuctionID

            let customKeySubject = PublishSubject<Currency>()
            subject.bidDollars = customKeySubject.asObservable()
            nav.loadViewProgrammatically()
            subject.loadViewProgrammatically()

            customKeySubject.onNext(33);

            expect(nav.bidDetails.bidAmountCents) == 3300
        }
    }
}
