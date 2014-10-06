import Quick
import Nimble

class RegisterFlowViewTests: QuickSpec {

    override func spec() {

        it("looks right by default") {

            let frame = CGRect(x: 0, y: 0, width: 180, height: 320)
            var bidDetails  = BidDetails(saleArtwork: nil, bidderID: nil, bidderPIN: nil, bidAmountCents: nil)
            bidDetails.newUser = NewUser()

            let sut = RegisterFlowView(frame: frame)
            sut.details = bidDetails
            expect(sut).to( haveValidSnapshot(named: "empty") )
        }

        it("handles partial data") {
            let frame = CGRect(x: 0, y: 0, width: 180, height: 320)
            var bidDetails  = BidDetails(saleArtwork: nil, bidderID: nil, bidderPIN: nil, bidAmountCents: nil)
            bidDetails.newUser = NewUser()

            bidDetails.newUser.phoneNumber = "132131231"
            bidDetails.newUser.email = "xxx@yyy.com"

            let sut = RegisterFlowView(frame: frame)
            sut.details = bidDetails
            expect(sut).to( haveValidSnapshot(named: "partial") )
        }

        it("handles different ") {
            let frame = CGRect(x: 0, y: 0, width: 180, height: 320)
            var bidDetails  = BidDetails(saleArtwork: nil, bidderID: nil, bidderPIN: nil, bidAmountCents: nil)
            bidDetails.newUser = NewUser()

            bidDetails.newUser.phoneNumber = "132131231"
            bidDetails.newUser.email = "xxx@yyy.com"

            let sut = RegisterFlowView(frame: frame)
            sut.highlightedIndex = 2
            sut.details = bidDetails
            expect(sut).to( haveValidSnapshot(named: "partial-different-highlight") )
        }


        it("handles full data") {
            let frame = CGRect(x: 0, y: 0, width: 180, height: 320)
            var bidDetails  = BidDetails(saleArtwork: nil, bidderID: nil, bidderPIN: nil, bidAmountCents: nil)
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
