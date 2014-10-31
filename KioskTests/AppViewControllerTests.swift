import Quick
import Nimble

class AppViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right") {
            let sut = UIStoryboard.auction().viewControllerWithID(.NoInternetConnection) as UIViewController
            expect(sut).to(haveValidSnapshot(named:"default"))
        }

        describe("view") {

            var sut: AppViewController!
            var fakeReachabilitySignal: RACSubject!
            var fakeView: UIView!

            beforeEach {
                sut = AppViewController()
                fakeReachabilitySignal = RACSubject()
                fakeView = UIView(frame:CGRectMake(0,0,20,20))

                sut.reachabilitySignal = fakeReachabilitySignal
                sut.offlineBlockingView = fakeView
            }

            it("shows the offlineBlockingView when offline signal is true"){
                fakeView.hidden = false

                sut.loadViewProgrammatically()
                fakeReachabilitySignal.sendNext(true)
                expect(fakeView.hidden) == true
            }

            it("hides the offlineBlockingView when offline signal is false"){

                fakeView.hidden = true
                expect(fakeView.hidden) == true
                
                sut.loadViewProgrammatically()
                fakeReachabilitySignal.sendNext(false)
                expect(fakeView.hidden) == false
                
            }

        }
    }
}
