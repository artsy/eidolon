import Quick
import Nimble
import Nimble_Snapshots
import ReactiveCocoa
import Kiosk

class AppViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right offline") {
            // TODO: This isn't working – causing Autolayout issues
            let subject = UIStoryboard.auction().viewControllerWithID(.NoInternetConnection) as UIViewController
            subject.loadViewProgrammatically()
            subject.view.backgroundColor = UIColor.blackColor()
            expect(subject).to(haveValidSnapshot())
        }

        describe("view") {
            var subject: AppViewController!
            var fakeReachabilitySignal: RACSubject!

            beforeEach {
                subject = AppViewController.instantiateFromStoryboard(auctionStoryboard)
                fakeReachabilitySignal = RACSubject()
                
                subject.reachabilitySignal = fakeReachabilitySignal
                subject.apiPingerSignal = RACSignal.`return`(true).take(1)
            }

            it("shows the offlineBlockingView when offline signal is true"){
                subject.loadViewProgrammatically()
                
                subject.offlineBlockingView.hidden = false
                
                fakeReachabilitySignal.sendNext(true)
                expect(subject.offlineBlockingView.hidden) == true
            }

            it("hides the offlineBlockingView when offline signal is false"){
                subject.loadViewProgrammatically()
                
                subject.offlineBlockingView.hidden = true
                expect(subject.offlineBlockingView.hidden) == true
                
                
                fakeReachabilitySignal.sendNext(false)
                expect(subject.offlineBlockingView.hidden) == false
                
            }

        }
    }
}
