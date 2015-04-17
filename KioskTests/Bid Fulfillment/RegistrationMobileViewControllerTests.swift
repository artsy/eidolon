import Quick
import Nimble
import Kiosk
import ReactiveCocoa
import Nimble_Snapshots
import Moya

class RegistrationMobileViewControllerTests: QuickSpec {
    override func spec() {
        it("looks right by default") {
            let subject = RegistrationMobileViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = BidDetails.stubbedBidDetails()
            expect(subject).to( haveValidSnapshot() )
        }

        it("looks right with existing mobile") {
            let subject = RegistrationMobileViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = BidDetails.stubbedBidDetails()
            subject.bidDetails.newUser.phoneNumber = "1234567890"
            expect(subject).to( haveValidSnapshot() )
        }
    }
}
