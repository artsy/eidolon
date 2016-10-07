import Quick
import Nimble
import Nimble_Snapshots
import RxSwift
@testable
import Kiosk

class AppViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right offline") {
            let subject = UIStoryboard.auction().viewController(withID: .NoInternetConnection) as UIViewController
            subject.loadViewProgrammatically()
            subject.view.backgroundColor = UIColor.black
            expect(subject).to(haveValidSnapshot())
        }

        describe("view") {
            var subject: AppViewController!
            var fakeReachability: Variable<Bool>!

            beforeEach {
                subject = AppViewController.instantiate(from: auctionStoryboard)
                subject.provider = Networking.newStubbingNetworking()
                fakeReachability = Variable(true)
                
                subject.reachability = fakeReachability.asObservable()
                subject.apiPinger = Observable.just(true).take(1)
            }

            it("shows the offlineBlockingView when offline  is true"){
                subject.loadViewProgrammatically()
                
                subject.offlineBlockingView.isHidden = false
                
                fakeReachability.value = true
                expect(subject.offlineBlockingView.isHidden) == true
            }

            it("hides the offlineBlockingView when offline  is false"){
                subject.loadViewProgrammatically()

                fakeReachability.value = true
                expect(subject.offlineBlockingView.isHidden) == true
                
                
                fakeReachability.value = false
                expect(subject.offlineBlockingView.isHidden) == false
                
            }
        }
    }
}
