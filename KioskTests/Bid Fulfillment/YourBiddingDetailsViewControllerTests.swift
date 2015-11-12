import Quick
import Nimble
@testable
import Kiosk
import RxSwift
import Nimble_Snapshots

class YourBiddingDetailsViewControllerTests: QuickSpec {
    override func spec() {
        it("displays bidder number and PIN") {
            let subject = YourBiddingDetailsViewController.instantiateFromStoryboard(fulfillmentStoryboard)
            subject.bidDetails = testBidDetails()
            subject.bidDetails.paddleNumber = "14589"
            subject.bidDetails.bidderPIN = "4468"

            expect(subject).to( haveValidSnapshot() )
        }
    }
}
