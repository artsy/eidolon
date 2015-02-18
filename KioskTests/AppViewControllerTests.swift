import Quick
import Nimble
import Nimble_Snapshots
import ReactiveCocoa
import Kiosk

class AppViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right offline") {
            let subject = UIStoryboard.auction().viewControllerWithID(.NoInternetConnection) as UIViewController
            subject.loadViewProgrammatically()
            subject.view.backgroundColor = UIColor.blackColor()
            expect(subject).to(haveValidSnapshot())
        }

        describe("view") {
            var subject: AppViewController!
            var fakeReachabilitySignal: RACSubject!
            var fakeView: UIView!

            beforeEach {
                subject = AppViewController()
                fakeReachabilitySignal = RACSubject()
                fakeView = UIView(frame:CGRectMake(0,0,20,20))

                subject.reachabilitySignal = fakeReachabilitySignal
                subject.offlineBlockingView = fakeView
            }

            it("shows the offlineBlockingView when offline signal is true"){
                fakeView.hidden = false

                subject.loadViewProgrammatically()
                fakeReachabilitySignal.sendNext(true)
                expect(fakeView.hidden) == true
            }

            it("hides the offlineBlockingView when offline signal is false"){

                fakeView.hidden = true
                expect(fakeView.hidden) == true
                
                subject.loadViewProgrammatically()

                fakeReachabilitySignal.sendNext(false)
                expect(fakeView.hidden) == false
                
            }

        }
    }
}
