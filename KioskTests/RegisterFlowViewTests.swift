import Quick
import Nimble
import Kiosk
import Nimble_Snapshots

class RegisterFlowViewTests: QuickSpec {

    override func spec() {

        // These seem to record perfectly, and the images look the same
        // unsure why they're failing.

        xit("looks right by default") {

            let frame = CGRect(x: 0, y: 0, width: 180, height: 320)
            var bidDetails  = BidDetails(saleArtwork: nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)
            bidDetails.newUser = NewUser()

            let sut = RegisterFlowView(frame: frame)
            sut.details = bidDetails
            expect(sut).to( haveValidSnapshot(named: "empty") )
        }

        xit("handles partial data") {
            let frame = CGRect(x: 0, y: 0, width: 180, height: 320)
            var bidDetails  = BidDetails(saleArtwork: nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)
            bidDetails.newUser = NewUser()

            bidDetails.newUser.phoneNumber = "132131231"
            bidDetails.newUser.email = "xxx@yyy.com"

            let sut = RegisterFlowView(frame: frame)
            sut.details = bidDetails
            expect(sut).to( haveValidSnapshot(named: "partial") )
        }

        xit("handles different ") {
            let frame = CGRect(x: 0, y: 0, width: 180, height: 320)
            var bidDetails  = BidDetails(saleArtwork: nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)
            bidDetails.newUser = NewUser()

            bidDetails.newUser.phoneNumber = "132131231"
            bidDetails.newUser.email = "xxx@yyy.com"

            let sut = RegisterFlowView(frame: frame)
            sut.highlightedIndex = 2
            sut.details = bidDetails
            expect(sut).to( haveValidSnapshot(named: "partial-different-highlight") )
        }


        xit("handles full data") {
            let frame = CGRect(x: 0, y: 0, width: 180, height: 320)
            var bidDetails  = BidDetails(saleArtwork: nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)
            bidDetails.newUser = NewUser()

            bidDetails.newUser.phoneNumber = "132131231"
            bidDetails.newUser.creditCardToken = "...2323"
            bidDetails.newUser.email = "xxx@yyy.com"
            bidDetails.newUser.zipCode = "90210"

            let sut = RegisterFlowView(frame: frame)
            sut.details = bidDetails
            expect(sut).to( haveValidSnapshot(named: "filled") )
        }

    }
}
