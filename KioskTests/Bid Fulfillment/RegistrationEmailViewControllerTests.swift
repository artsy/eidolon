import Quick
import Nimble
@testable
import Kiosk
import Nimble_Snapshots

class RegistrationEmailViewControllerTests: QuickSpec {
    override func spec() {
        it("looks right by default") {
            let subject = RegistrationEmailViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = testBidDetails()
            expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
        }

        it("looks right with existing email") {
            let subject = RegistrationEmailViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = testBidDetails()
            subject.bidDetails.newUser.email.value = "test@example.com"
            expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
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
            _ = runLifecycleOfViewController(bidDetails)

            expect { runLifecycleOfViewController(bidDetails) }.toNot( raiseException() )
        }
    }
}
