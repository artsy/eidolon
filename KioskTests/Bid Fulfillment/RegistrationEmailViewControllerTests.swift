import Quick
import Nimble
@testable
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
            subject.bidDetails.newUser.email.value = "test@example.com"
            expect(subject).to( haveValidSnapshot() )
        }

        it("unbinds bidDetails on viewWillDisappear:") {
            let runLifecycleOfViewController = { (bidDetails: BidDetails) -> RegistrationEmailViewController in
                let subject = RegistrationEmailViewController.instantiateFromStoryboard(fulfillmentStoryboard)
                subject.bidDetails = bidDetails
                subject.loadViewProgrammatically()
                subject.viewWillDisappear(false)
                return subject
            }

            let bidDetails = testBidDetails()
            runLifecycleOfViewController(bidDetails)

            expect { runLifecycleOfViewController(bidDetails) }.toNot( raiseException() )
        }
    }
}
