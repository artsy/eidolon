import Quick
import Nimble
@testable
import Kiosk
import RxSwift
import Nimble_Snapshots
import Moya

class RegistrationMobileViewControllerTests: QuickSpec {
    override func spec() {
        it("looks right by default") {
            let subject = RegistrationMobileViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = testBidDetails()
            expect(subject).to( haveValidSnapshot() )
        }

        it("looks right with existing mobile") {
            let subject = RegistrationMobileViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = testBidDetails()
            subject.bidDetails.newUser.phoneNumber.value = "1234567890"
            expect(subject).to( haveValidSnapshot() )
        }

        it("unbinds bidDetails on viewWillDisappear:") {
            let runLifecycleOfViewController = { (bidDetails: BidDetails) -> RegistrationMobileViewController in
                let subject = RegistrationMobileViewController.instantiateFromStoryboard(fulfillmentStoryboard)
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
