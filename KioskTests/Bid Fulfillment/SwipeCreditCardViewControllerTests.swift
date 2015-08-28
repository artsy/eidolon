import Quick
import Nimble
@testable
import Kiosk

class SwipeCreditCardViewControllerTests: QuickSpec {
    override func spec() {
        it("unbinds bidDetails on viewWillDisappear:") {
            let runLifecycleOfViewController = { (bidDetails: BidDetails) -> SwipeCreditCardViewController in
                let subject = SwipeCreditCardViewController.instantiateFromStoryboard(fulfillmentStoryboard)
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
