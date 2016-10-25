import Quick
import Nimble
@testable
import Kiosk
import Nimble_Snapshots

class RegistrationPostalViewControllerTests: QuickSpec {
    override func spec() {
        it("looks right by default") {
            let subject = RegistrationPostalZipViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = testBidDetails()
            expect(subject).to( haveValidSnapshot() )
        }

        it("looks right with existing postal code") {
            let subject = RegistrationPostalZipViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = testBidDetails()
            subject.bidDetails.newUser.zipCode.value = "A1A1A1"
            expect(subject).to( haveValidSnapshot() )
        }

        it("unbinds bidDetails on viewWillDisappear:") {
            let runLifecycleOfViewController = { (bidDetails: BidDetails) -> RegistrationPostalZipViewController in
                let subject = RegistrationPostalZipViewController.instantiateFromStoryboard(fulfillmentStoryboard)
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
