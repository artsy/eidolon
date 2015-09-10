import Quick
import Nimble
@testable
import Kiosk
import ReactiveCocoa

class LoadingViewModelTests: QuickSpec {
    override func spec() {
        var subject: LoadingViewModel!

        it("loads placeBidNetworkModel") {
            subject = LoadingViewModel(bidNetworkModel: StubBidderNetworkModel(), placingBid: false)
            expect(subject.placeBidNetworkModel.fulfillmentController as? AnyObject) === subject.bidderNetworkModel.fulfillmentController as? AnyObject
        }

        it("loads bidCheckingModel") {
            subject = LoadingViewModel(bidNetworkModel: StubBidderNetworkModel(), placingBid: false)
            expect(subject.bidCheckingModel.fulfillmentController as? AnyObject) === subject.bidderNetworkModel.fulfillmentController as? AnyObject
        }

        it("initializes with bidNetworkModel") {
            let networkModel = StubBidderNetworkModel()
            subject = LoadingViewModel(bidNetworkModel: networkModel, placingBid: false)

            expect(subject.bidderNetworkModel) == networkModel
        }

        it("initializes with placingBid = false") {
            subject = LoadingViewModel(bidNetworkModel: StubBidderNetworkModel(), placingBid: false)

            expect(subject.placingBid) == false
        }

        it("initializes with placingBid = true") {
            subject = LoadingViewModel(bidNetworkModel: StubBidderNetworkModel(), placingBid: true)

            expect(subject.placingBid) == true
        }

        it("binds createdNewBidder") {
            subject = LoadingViewModel(bidNetworkModel: StubBidderNetworkModel(), placingBid: true)
            subject.bidderNetworkModel.createdNewBidder = true

            expect(subject.createdNewBidder) == true
        }

        it("binds bidIsResolved") {
            subject = LoadingViewModel(bidNetworkModel: StubBidderNetworkModel(), placingBid: true)
            subject.bidCheckingModel.bidIsResolved = true

            expect(subject.bidIsResolved) == true
        }

        it("binds isHighestBidder") {
            subject = LoadingViewModel(bidNetworkModel: StubBidderNetworkModel(), placingBid: true)
            subject.bidCheckingModel.isHighestBidder = true

            expect(subject.isHighestBidder) == true
        }

        it("binds reserveNotMet") {
            subject = LoadingViewModel(bidNetworkModel: StubBidderNetworkModel(), placingBid: true)
            subject.bidCheckingModel.reserveNotMet = true

            expect(subject.reserveNotMet) == true
        }

        it("infers bidDetals") {
            subject = LoadingViewModel(bidNetworkModel: StubBidderNetworkModel(), placingBid: true)
            expect(subject.bidDetails) === subject.bidderNetworkModel.fulfillmentController.bidDetails
        }

        it("creates a new bidder if necessary") {
            subject = LoadingViewModel(bidNetworkModel: StubBidderNetworkModel(), placingBid: false)
            kioskWaitUntil { (done) in
                subject.performActions().subscribeCompleted { done() }
            }

            expect(subject.createdNewBidder = true)
        }

        describe("stubbed auxillary network models") {
            var stubPlaceBidNetworkModel: StubPlaceBidNetworkModel!
            var stubBidCheckingNetworkModel: StubBidCheckingNetworkModel!

            beforeEach {
                stubPlaceBidNetworkModel = StubPlaceBidNetworkModel()
                stubBidCheckingNetworkModel = StubBidCheckingNetworkModel()

                subject = LoadingViewModel(bidNetworkModel: StubBidderNetworkModel(), placingBid: true)

                subject.placeBidNetworkModel = stubPlaceBidNetworkModel
                subject.bidCheckingModel = stubBidCheckingNetworkModel
            }

            it("places a bid if necessary") {
                kioskWaitUntil { (done) -> Void in
                    subject.performActions().subscribeCompleted { done() }
                    return
                }

                expect(stubPlaceBidNetworkModel.bid) == true
            }

            it("waits for bid resolution if bid was placed") {
                kioskWaitUntil { (done) -> Void in
                    subject.performActions().subscribeCompleted { done() }
                    return
                }

                expect(stubBidCheckingNetworkModel.checked) == true
            }
        }
    }
}

class StubBidderNetworkModel: BidderNetworkModel {
    init() {
        super.init(fulfillmentController: StubFulfillmentController())
    }

    override func createOrGetBidder() -> RACSignal {
        createdNewBidder = true
        return RACSignal.empty()
    }
}

class StubPlaceBidNetworkModel: PlaceBidNetworkModel {
    var bid = false

    init() {
        super.init(fulfillmentController: StubFulfillmentController())
    }

    override func bidSignal(bidDetails: BidDetails) -> RACSignal {
        bid = true

        return RACSignal.empty()
    }
}

class StubBidCheckingNetworkModel: BidCheckingNetworkModel {
    var checked = false

    init() {
        super.init(fulfillmentController: StubFulfillmentController())
    }

    override func waitForBidResolution() -> RACSignal {
        checked = true

        return RACSignal.empty()
    }
}
