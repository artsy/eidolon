import Quick
import Nimble
import Kiosk
import Nimble_Snapshots

class RegistrationEmailViewControllerTests: QuickSpec {
    override func spec() {
        it("looks right by default") {
            let subject = RegistrationEmailViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = BidDetails.stubbedBidDetails()
            expect(subject).to( haveValidSnapshot() )
        }

        it("looks right with existing email") {
            let subject = RegistrationEmailViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = BidDetails.stubbedBidDetails()
            subject.bidDetails.newUser.email = "test@example.com"
            expect(subject).to( haveValidSnapshot() )
        }
    }
}
