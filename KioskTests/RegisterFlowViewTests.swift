import Quick
import Nimble
@testable
import Kiosk
import Nimble_Snapshots

private let frame = CGRect(x: 0, y: 0, width: 180, height: 320)

class RegisterFlowViewConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("a register flow view") { (sharedExampleContext: @escaping SharedExampleContext) in
            var subject: RegisterFlowView!

            beforeEach {
                subject = sharedExampleContext()["subject"] as! RegisterFlowView
            }

            it("looks right by default") {
                let bidDetails  = BidDetails(saleArtwork: nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil, auctionID: testAuctionID)
                bidDetails.newUser = NewUser()

                subject.details = bidDetails

                subject.snapshotView(afterScreenUpdates: true)
                expect(subject).to( haveValidSnapshot() )
            }

            it("handles partial data") {
                let bidDetails  = BidDetails(saleArtwork: nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil, auctionID: testAuctionID)
                bidDetails.newUser = NewUser()

                bidDetails.newUser.phoneNumber.value = "132131231"
                bidDetails.newUser.email.value = "xxx@yyy.com"

                subject.details = bidDetails

                subject.snapshotView(afterScreenUpdates: true)
                expect(subject).to( haveValidSnapshot() )
            }

            it("handles highlighted index") {
                let bidDetails  = BidDetails(saleArtwork: nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil, auctionID: testAuctionID)
                bidDetails.newUser = NewUser()

                bidDetails.newUser.phoneNumber.value = "132131231"
                bidDetails.newUser.email.value = "xxx@yyy.com"

                subject.highlightedIndex.value = 2
                subject.details = bidDetails

                subject.snapshotView(afterScreenUpdates: true)
                expect(subject).to( haveValidSnapshot() )
            }


            it("handles full data") {
                let bidDetails  = BidDetails(saleArtwork: nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil, auctionID: testAuctionID)
                bidDetails.newUser = NewUser()

                bidDetails.newUser.phoneNumber.value = "132131231"
                bidDetails.newUser.creditCardToken.value = "...2323"
                bidDetails.newUser.email.value = "xxx@yyy.com"
                bidDetails.newUser.zipCode.value = "90210"
                subject.details = bidDetails

                subject.snapshotView(afterScreenUpdates: true)
                expect(subject).to( haveValidSnapshot() )
            }
        }
    }
}

class RegisterFlowViewTests: QuickSpec {
    override func spec() {
        var appSetup: AppSetup!
        var subject: RegisterFlowView!

        beforeEach {
            appSetup = AppSetup()
            subject = RegisterFlowView(frame: frame)
            subject.constrainWidth("180")
            subject.constrainHeight("320")
            subject.appSetup = appSetup
            subject.backgroundColor = .white
        }

        describe("requiring zip code") {
            itBehavesLike("a register flow view") { () -> (NSDictionary) in
                appSetup.disableCardReader = true
                return ["subject": subject]
            }
        }

        describe("not requiring zip code") {
            itBehavesLike("a register flow view") { () -> (NSDictionary) in
                appSetup.disableCardReader = false
                return ["subject": subject]
            }
        }
    }
}
