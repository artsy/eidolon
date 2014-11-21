import Quick
import Nimble
import Kiosk
import ReactiveCocoa
import Nimble_Snapshots

class LoadingViewControllerTests: QuickSpec {
    override func spec() {
        let storyboard =  UIStoryboard.fulfillment()
        var sut: LoadingViewController!

        describe("default") {
            beforeEach {
                sut = storyboard.viewControllerWithID(.LoadingBidsorRegistering).wrapInFulfillmentNav() as LoadingViewController
                sut.bidderNetworkModel = ErrorBidderNetworkModel()
                sut.bidCheckingModel = DummyBidCheckingNetworkModel(details: BidDetails(string: ""), provider: Provider.StubbingProvider())
                sut.placeBidNetworkModel = DummyPlaceBidNetworkModel()
                sut.details = BidDetails.stubbedBidDetails()
                sut.performNetworking = false
                sut.animate = false
            }

            it("placing a bid") {
                sut.placingBid = true
                expect(sut).to(haveValidSnapshot())
            }

            it("registering a user") {
                sut.placingBid = false
                expect(sut).to(haveValidSnapshot())
            }
        }

        describe("errors") {
            beforeEach {
                sut = storyboard.viewControllerWithID(.LoadingBidsorRegistering).wrapInFulfillmentNav() as LoadingViewController
                sut.bidderNetworkModel = ErrorBidderNetworkModel()
                sut.bidCheckingModel = DummyBidCheckingNetworkModel(details: BidDetails(string: ""), provider: Provider.StubbingProvider())
                sut.placeBidNetworkModel = DummyPlaceBidNetworkModel()
                sut.details = BidDetails.stubbedBidDetails()
            }

            it("correctly placing a bid") {
                sut.placingBid = true
                expect(sut).to(haveValidSnapshot())
            }

            it("correctly registering a user") {
                sut.placingBid = false
                expect(sut).to(haveValidSnapshot())
            }
        }

        describe("ending") {
            beforeEach {
                sut = storyboard.viewControllerWithID(.LoadingBidsorRegistering).wrapInFulfillmentNav() as LoadingViewController
                sut.bidderNetworkModel = SuccessBidderNetworkModel()
                sut.bidCheckingModel = DummyBidCheckingNetworkModel(details: BidDetails(string: ""), provider: Provider.StubbingProvider())
                sut.placeBidNetworkModel = DummyPlaceBidNetworkModel()
                sut.details = BidDetails.stubbedBidDetails()
            }

            it("placing bid success highest") {
                sut.placingBid = true
                sut.bidCheckingModel.bidIsResolved = true
                sut.bidCheckingModel.isHighestBidder = true

                expect(sut).to(haveValidSnapshot())
            }

            it("placing bid success not highest") {
                sut.placingBid = true
                sut.bidCheckingModel.bidIsResolved = true
                sut.bidCheckingModel.isHighestBidder = false

                expect(sut).to(haveValidSnapshot())
            }

            it("placing bid not resolved") {
                sut.placingBid = true
                sut.bidCheckingModel.bidIsResolved = true

                expect(sut).to(haveValidSnapshot())
            }

            it("registering user success") {
                sut.placingBid = false
                sut.bidderNetworkModel.createdNewBidder = true
                sut.bidCheckingModel.bidIsResolved = true

                expect(sut).to(haveValidSnapshot())
            }

            it("registering user not resolved") {
                sut.placingBid = false
                sut.bidCheckingModel.bidIsResolved = true

                expect(sut).to(haveValidSnapshot())
            }
        }
    }
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
