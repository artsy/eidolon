import Quick
import Nimble
import Nimble_Snapshots
import RxSwift
@testable
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
            var fakeReachabilitySignal: Variable<Bool>!

            beforeEach {
                subject = AppViewController.instantiateFromStoryboard(auctionStoryboard)
                fakeReachabilitySignal = Variable(true)
                
                subject.reachabilitySignal = fakeReachabilitySignal.asObservable()
                subject.apiPingerSignal = just(true).take(1)
            }

            it("shows the offlineBlockingView when offline signal is true"){
                subject.loadViewProgrammatically()
                
                subject.offlineBlockingView.hidden = false
                
                fakeReachabilitySignal.value = true
                expect(subject.offlineBlockingView.hidden) == true
            }

            it("hides the offlineBlockingView when offline signal is false"){
                subject.loadViewProgrammatically()

                fakeReachabilitySignal.value = true
                expect(subject.offlineBlockingView.hidden) == true
                
                
                fakeReachabilitySignal.value = false
                expect(subject.offlineBlockingView.hidden) == false
                
            }
        }
    }
}
