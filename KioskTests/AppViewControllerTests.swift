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
            var fakeReachability: Variable<Bool>!

            beforeEach {
                subject = AppViewController.instantiateFromStoryboard(auctionStoryboard)
                subject.provider = Networking.newStubbingNetworking()
                fakeReachability = Variable(true)
                
                subject.reachability = fakeReachability.asObservable()
                subject.apiPinger = just(true).take(1)
            }

            it("shows the offlineBlockingView when offline  is true"){
                subject.loadViewProgrammatically()
                
                subject.offlineBlockingView.hidden = false
                
                fakeReachability.value = true
                expect(subject.offlineBlockingView.hidden) == true
            }

            it("hides the offlineBlockingView when offline  is false"){
                subject.loadViewProgrammatically()

                fakeReachability.value = true
                expect(subject.offlineBlockingView.hidden) == true
                
                
                fakeReachability.value = false
                expect(subject.offlineBlockingView.hidden) == false
                
            }
        }
    }
}
