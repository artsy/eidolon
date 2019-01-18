import Quick
import Nimble
@testable
import Kiosk
import RxSwift
import Nimble_Snapshots
import Moya

class RegistrationNameViewControllerTests: QuickSpec {
  override func spec() {
    it("looks right by default") {
      let subject = RegistrationNameViewController.instantiateFromStoryboard(fulfillmentStoryboard)
      subject.bidDetails = testBidDetails()
      expect(subject).to( haveValidSnapshot() )
    }

    it("looks right with existing name") {
      let subject = RegistrationNameViewController.instantiateFromStoryboard(fulfillmentStoryboard)
      subject.bidDetails = testBidDetails()
      subject.bidDetails.newUser.name.value = "Fname Lname"
      expect(subject).to( haveValidSnapshot() )
    }

    it("unbinds bidDetails on viewWillDisappear:") {
      let runLifecycleOfViewController = { (bidDetails: BidDetails) -> RegistrationNameViewController in
        let subject = RegistrationNameViewController.instantiateFromStoryboard(fulfillmentStoryboard)
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
