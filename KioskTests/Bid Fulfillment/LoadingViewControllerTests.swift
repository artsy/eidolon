import Quick
import Nimble
import Kiosk
import ReactiveCocoa
import Nimble_Snapshots

class LoadingViewControllerTests: QuickSpec {
    override func spec() {
        var subject: LoadingViewController!

        beforeEach {
            subject = testLoadingViewController()
        }

        describe("default") {
            beforeEach {

                subject.bidderNetworkModel = ErrorBidderNetworkModel()
                subject.bidCheckingModel = DummyBidCheckingNetworkModel(details: BidDetails(string: ""), provider: Provider.StubbingProvider())
                subject.placeBidNetworkModel = DummyPlaceBidNetworkModel()
                subject.performNetworking = false
                subject.animate = false
            }

            it("placing a bid") {
                subject.placingBid = true
                expect(subject).to(haveValidSnapshot())
            }

            it("registering a user") {
                subject.placingBid = false
                expect(subject).to(haveValidSnapshot())
            }
        }

        describe("errors") {
            beforeEach {
                subject.bidderNetworkModel = ErrorBidderNetworkModel()
                subject.bidCheckingModel = DummyBidCheckingNetworkModel(details: BidDetails(string: ""), provider: Provider.StubbingProvider())
                subject.placeBidNetworkModel = DummyPlaceBidNetworkModel()
            }

            it("correctly placing a bid") {
                subject.placingBid = true
                expect(subject).to(haveValidSnapshot())
            }

            it("correctly registering a user") {
                subject.placingBid = false
                expect(subject).to(haveValidSnapshot())
            }
        }

        describe("ending") {
            beforeEach {
                subject.bidderNetworkModel = SuccessBidderNetworkModel()
                subject.bidCheckingModel = DummyBidCheckingNetworkModel(details: BidDetails(string: ""), provider: Provider.StubbingProvider())
                subject.placeBidNetworkModel = DummyPlaceBidNetworkModel()
            }

            it("placing bid success highest") {
                subject.placingBid = true
                subject.bidCheckingModel.bidIsResolved = true
                subject.bidCheckingModel.isHighestBidder = true

                expect(subject).to(haveValidSnapshot())
            }

            it("placing bid success not highest") {
                subject.placingBid = true
                subject.bidCheckingModel.bidIsResolved = true
                subject.bidCheckingModel.isHighestBidder = false

                expect(subject).to(haveValidSnapshot())
            }

            it("placing bid not resolved") {
                subject.placingBid = true
                subject.bidCheckingModel.bidIsResolved = true

                expect(subject).to(haveValidSnapshot())
            }

            it("registering user success") {
                subject.placingBid = false
                subject.bidderNetworkModel.createdNewBidder = true
                subject.bidCheckingModel.bidIsResolved = true

                expect(subject).to(haveValidSnapshot())
            }

            it("registering user not resolved") {
                subject.placingBid = false
                subject.bidCheckingModel.bidIsResolved = true

                expect(subject).to(haveValidSnapshot())
            }
        }
    }
}

let loadingViewControllerTestImage = UIImage.testImage(named: "artwork", ofType: "jpg")

func testLoadingViewController() -> LoadingViewController {
    let controller = UIStoryboard.fulfillment().viewControllerWithID(.LoadingBidsorRegistering).wrapInFulfillmentNav() as LoadingViewController
    controller.bidDetails = {
        let bidDetails = BidDetails.stubbedBidDetails()
        bidDetails.setImage = { (_, imageView) -> () in
            imageView.image = loadingViewControllerTestImage
        }
        return bidDetails
    }

    return controller
}

public class SuccessBidderNetworkModel: BidderNetworkModel {
    override public func createOrGetBidder() -> RACSignal {
        return RACSignal.empty()
    }
}

public class ErrorBidderNetworkModel: BidderNetworkModel {
    override public func createOrGetBidder() -> RACSignal {
        return RACSignal.error(NSError(domain: "", code: 0, userInfo: nil))
    }
}

public class DummyBidCheckingNetworkModel: BidCheckingNetworkModel {
    override public func waitForBidResolution() -> RACSignal {
        return RACSignal.empty()
    }
}

public class DummyPlaceBidNetworkModel: PlaceBidNetworkModel {
    override public func bidSignal(bidDetails: BidDetails) -> RACSignal {
        return RACSignal.empty()
    }
}
