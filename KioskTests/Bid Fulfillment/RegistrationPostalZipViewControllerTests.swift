import Quick
import Nimble
import Kiosk
import Nimble_Snapshots

class RegistrationPostalViewControllerTests: QuickSpec {
    override func spec() {
        it("looks right by default") {
            let subject = RegistrationPostalZipViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = BidDetails.stubbedBidDetails()
            expect(subject).to( haveValidSnapshot() )
        }

        it("looks right with existing postal code") {
            let subject = RegistrationPostalZipViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = BidDetails.stubbedBidDetails()
            subject.bidDetails.newUser.zipCode = "A1A1A1"
            expect(subject).to( haveValidSnapshot() )
        }
    }
}
