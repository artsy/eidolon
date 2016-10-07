import Quick
import Nimble
@testable
import Kiosk
import Moya
import RxSwift
import Nimble_Snapshots
import Forgeries

class LoadingViewControllerTests: QuickSpec {
    override func spec() {
        var subject: LoadingViewController!

        beforeEach {
            subject = testLoadingViewController()
            subject.animate = false
        }

        describe("default") {

            it("placing a bid") {
                subject.placingBid = true
                let fulfillmentController = StubFulfillmentController()
                let stubViewModel = StubLoadingViewModel(bidDetails: fulfillmentController.bidDetails)
                stubViewModel.completes = false
                subject.viewModel = stubViewModel

                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }

            it("registering a user") {
                subject.placingBid = false
                let fulfillmentController = StubFulfillmentController()
                let stubViewModel = StubLoadingViewModel(bidDetails: fulfillmentController.bidDetails)
                stubViewModel.completes = false
                subject.viewModel = stubViewModel

                expect(subject).to(haveValidSnapshot())
            }
        }

        describe("errors") {

            it("correctly placing a bid") {
                subject.placingBid = true
                let fulfillmentController = StubFulfillmentController()
                let stubViewModel = StubLoadingViewModel(bidDetails: fulfillmentController.bidDetails)
                stubViewModel.errors = true
                subject.viewModel = stubViewModel

                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }

            it("correctly registering a user") {
                subject.placingBid = false
                let fulfillmentController = StubFulfillmentController()
                let stubViewModel = StubLoadingViewModel(bidDetails: fulfillmentController.bidDetails)
                stubViewModel.errors = true
                subject.viewModel = stubViewModel

                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }
        }

        describe("ending") {

            it("placing bid success highest") {
                subject.placingBid = true
                let fulfillmentController = StubFulfillmentController()
                let stubViewModel = StubLoadingViewModel(bidDetails: fulfillmentController.bidDetails)
                stubViewModel.bidIsResolved.value = true
                stubViewModel.isHighestBidder.value = true
                subject.viewModel = stubViewModel

                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }

            it("dismisses by tapping green checkmark when bidding was a success") {
                subject.placingBid = true
                let fulfillmentController = StubFulfillmentController()
                let stubViewModel = StubLoadingViewModel(bidDetails: fulfillmentController.bidDetails)
                stubViewModel.bidIsResolved.value = true
                stubViewModel.isHighestBidder.value = true
                subject.viewModel = stubViewModel

                var closed = false

                subject.closeSelf = {
                    closed = true
                }

                let testingRecognizer = ForgeryTapGestureRecognizer()
                subject.recognizer = testingRecognizer

                subject.loadViewProgrammatically()
                testingRecognizer.invoke()

                expect(closed).to( beTrue() )
            }

            it("placing bid success not highest") {
                subject.placingBid = true
                let fulfillmentController = StubFulfillmentController()
                let stubViewModel = StubLoadingViewModel(bidDetails: fulfillmentController.bidDetails)
                stubViewModel.bidIsResolved.value = true
                stubViewModel.isHighestBidder.value = false
                subject.viewModel = stubViewModel

                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }

            it("placing bid error due to outbid") {
                subject.placingBid = true
                let fulfillmentController = StubFulfillmentController()
                let stubViewModel = StubLoadingViewModel(bidDetails: fulfillmentController.bidDetails)
                subject.viewModel = stubViewModel

                subject.loadViewProgrammatically()

                let error = NSError(domain: OutbidDomain, code: 0, userInfo: nil)
                subject.bidderError(error)

                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }

            it("placing bid succeeded but not resolved") {
                subject.placingBid = true
                let fulfillmentController = StubFulfillmentController()
                let stubViewModel = StubLoadingViewModel(bidDetails: fulfillmentController.bidDetails)
                stubViewModel.bidIsResolved.value = false
                subject.viewModel = stubViewModel

                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }

            it("registering user success") {
                subject.placingBid = false
                let fulfillmentController = StubFulfillmentController()
                let stubViewModel = StubLoadingViewModel(bidDetails: fulfillmentController.bidDetails)
                stubViewModel.createdNewBidder.value = true
                stubViewModel.bidIsResolved.value = true
                subject.viewModel = stubViewModel

                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }

            it("registering user not resolved") {
                subject.placingBid = false
                let fulfillmentController = StubFulfillmentController()
                let stubViewModel = StubLoadingViewModel(bidDetails: fulfillmentController.bidDetails)
                stubViewModel.bidIsResolved.value = true
                subject.viewModel = stubViewModel

                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }
        }
    }
}

let loadingViewControllerTestImage = UIImage.testImage(named: "artwork", ofType: "jpg")

func testLoadingViewController() -> LoadingViewController {
    let controller = UIStoryboard.fulfillment().viewController(withID: .LoadingBidsorRegistering).wrapInFulfillmentNav() as! LoadingViewController
    return controller
}

class StubLoadingViewModel: LoadingViewModelType {
    var errors = false
    var completes = true

    // LoadingViewModelType conformance
    let createdNewBidder = Variable(false)
    let bidIsResolved = Variable(false)
    let isHighestBidder = Variable(false)
    let reserveNotMet = Variable(false)

    var bidDetails: BidDetails

    init(bidDetails: BidDetails) {
        self.bidDetails = bidDetails
    }

    func performActions() -> Observable<Void> {
        if completes {
            if errors {
                return Observable.error(NSError(domain: "", code: 0, userInfo: nil) as Swift.Error)
            } else {
                return Observable.empty()
            }
        } else {
            return Observable.never()
        }
    }
}
