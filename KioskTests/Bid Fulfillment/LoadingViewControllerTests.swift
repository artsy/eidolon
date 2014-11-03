import Quick
import Nimble

class LoadingViewControllerTests: QuickSpec {
    override func spec() {
        let storyboard =  UIStoryboard.fulfillment()
        var sut: LoadingViewController!

        describe("default") {
            beforeEach {
                sut = storyboard.viewControllerWithID(.LoadingBidsorRegistering) as LoadingViewController
                sut.bidderNetworkModel = ErrorBidderNetworkModel()
                sut.bidCheckingModel = DummyBidCheckingNetworkModel(details: BidDetails(string: ""), provider: Provider.StubbingProvider())
                sut.placeBidNetworkModel = DummyPlaceBidNetworkModel()
                sut.details = BidDetails.stubbedBidDetails()
                sut.performNetworking = false
                sut.animate = false
            }

            it("placing a bid") {
                sut.placingBid = true
                expect(sut).to(haveValidSnapshot(named:"placing a bid"))
            }

            it("registering a user") {
                sut.placingBid = false
                expect(sut).to(haveValidSnapshot(named:"registering a user"))
            }
        }

        describe("errors") {
            beforeEach {
                sut = storyboard.viewControllerWithID(.LoadingBidsorRegistering) as LoadingViewController
                sut.bidderNetworkModel = ErrorBidderNetworkModel()
                sut.bidCheckingModel = DummyBidCheckingNetworkModel(details: BidDetails(string: ""), provider: Provider.StubbingProvider())
                sut.placeBidNetworkModel = DummyPlaceBidNetworkModel()
                sut.details = BidDetails.stubbedBidDetails()
            }

            it("correctly placing a bid") {
                sut.placingBid = true
                expect(sut).to(haveValidSnapshot(named:"errors correctly placing a bid"))
            }

            it("correctly registering a user") {
                sut.placingBid = false
                expect(sut).to(haveValidSnapshot(named:"errors correctly registering a user"))
            }
        }

        describe("ending") {
            beforeEach {
                sut = storyboard.viewControllerWithID(.LoadingBidsorRegistering) as LoadingViewController
                sut.bidderNetworkModel = SuccessBidderNetworkModel()
                sut.bidCheckingModel = DummyBidCheckingNetworkModel(details: BidDetails(string: ""), provider: Provider.StubbingProvider())
                sut.placeBidNetworkModel = DummyPlaceBidNetworkModel()
                sut.details = BidDetails.stubbedBidDetails()
            }

            it("placing bid success highest") {
                sut.placingBid = true
                sut.bidCheckingModel.bidIsResolved = true
                sut.bidCheckingModel.isHighestBidder = true

                expect(sut).to(haveValidSnapshot(named:"placing bid success highest"))
            }

            it("placing bid success not higest") {
                sut.placingBid = true
                sut.bidCheckingModel.bidIsResolved = true
                sut.bidCheckingModel.isHighestBidder = false

                expect(sut).to(haveValidSnapshot(named:"placing bid success not higest"))
            }

            it("placing bid not resolved") {
                sut.placingBid = true
                sut.bidCheckingModel.bidIsResolved = true

                expect(sut).to(haveValidSnapshot(named:"placing bid not resolved"))
            }

            it("registering user success") {
                sut.placingBid = false
                sut.bidderNetworkModel.createdNewBidder = true
                sut.bidCheckingModel.bidIsResolved = true
                expect(sut).to(haveValidSnapshot(named:"registering user success"))
            }

            it("registering user not resolved") {
                sut.placingBid = false
                sut.bidCheckingModel.bidIsResolved = true
                expect(sut).to(haveValidSnapshot(named:"registering user not resolved"))
            }

        }

    }
}

class SuccessBidderNetworkModel: BidderNetworkModel {
    override func createOrGetBidder() -> RACSignal {
        return RACSignal.empty()
    }
}

class ErrorBidderNetworkModel: BidderNetworkModel {
    override func createOrGetBidder() -> RACSignal {
        return RACSignal.error(NSError(domain: "", code: 0, userInfo: nil))
    }
}

class DummyBidCheckingNetworkModel: BidCheckingNetworkModel {
    override func waitForBidResolution() -> RACSignal {
        return RACSignal.empty()
    }
}

class DummyPlaceBidNetworkModel: PlaceBidNetworkModel {
    override func bidSignal(bidDetails: BidDetails) -> RACSignal {
        return RACSignal.empty()
    }
}
