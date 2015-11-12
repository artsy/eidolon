import Quick
import Nimble
@testable
import Kiosk
import RxSwift

class LoadingViewModelTests: QuickSpec {
    override func spec() {
        var stubbedNetworkModel: StubBidderNetworkModel!
        var subject: LoadingViewModel!

        beforeEach {
            // The subject's reference to its network model is unowned, so we must take responsibility for it.
            stubbedNetworkModel = StubBidderNetworkModel()
        }

        it("loads placeBidNetworkModel") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: false, actionsCompleteSignal: RACSignal.never())
            expect(subject.placeBidNetworkModel.fulfillmentController as AnyObject) === subject.bidderNetworkModel.fulfillmentController
        }

        it("loads bidCheckingModel") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: false, actionsCompleteSignal: RACSignal.never())
            expect(subject.bidCheckingModel.fulfillmentController as AnyObject) === subject.bidderNetworkModel.fulfillmentController
        }

        it("initializes with bidNetworkModel") {
            let networkModel = StubBidderNetworkModel()
            subject = LoadingViewModel(bidNetworkModel: networkModel, placingBid: false, actionsCompleteSignal: RACSignal.never())

            expect(subject.bidderNetworkModel) == networkModel
        }

        it("initializes with placingBid = false") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: false, actionsCompleteSignal: RACSignal.never())

            expect(subject.placingBid) == false
        }

        it("initializes with placingBid = true") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: RACSignal.never())

            expect(subject.placingBid) == true
        }

        it("binds createdNewBidder") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: RACSignal.never())
            stubbedNetworkModel.createdNewBidderSubject.sendNext(true)

            expect(subject.createdNewBidder) == true
        }

        it("binds bidIsResolved") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: RACSignal.never())
            subject.bidCheckingModel.bidIsResolved = true

            expect(subject.bidIsResolved) == true
        }

        it("binds isHighestBidder") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: RACSignal.never())
            subject.bidCheckingModel.isHighestBidder = true

            expect(subject.isHighestBidder) == true
        }

        it("binds reserveNotMet") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: RACSignal.never())
            subject.bidCheckingModel.reserveNotMet = true

            expect(subject.reserveNotMet) == true
        }

        it("infers bidDetals") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: RACSignal.never())
            expect(subject.bidDetails) === subject.bidderNetworkModel.fulfillmentController.bidDetails
        }

        it("creates a new bidder if necessary") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: false, actionsCompleteSignal: RACSignal.never())
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

                subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: RACSignal.never())

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

let bidderID = "some-bidder-id"

class StubBidderNetworkModel: BidderNetworkModel {
    var createdNewBidderSubject = RACSubject()
    // Our superclass' reference is unowned, so we need to retain it.
    let _stubbedFulfillmentController = StubFulfillmentController()

    init() {
        super.init(fulfillmentController: _stubbedFulfillmentController)
    }

    override func createOrGetBidder() -> RACSignal {
        createdNewBidderSubject.sendNext(true)
        return RACSignal.empty()
    }

    override var createdNewUser: RACSignal {
        return createdNewBidderSubject.startWith(false)
    }
}

class StubPlaceBidNetworkModel: PlaceBidNetworkModel {
    var bid = false

    init() {
        super.init(fulfillmentController: StubFulfillmentController())
    }

    override func bidSignal() -> RACSignal {
        bid = true

        return RACSignal.`return`(bidderID)
    }
}

class StubBidCheckingNetworkModel: BidCheckingNetworkModel {
    var checked = false

    init() {
        super.init(fulfillmentController: StubFulfillmentController())
    }

    override func waitForBidResolution(_: String) -> RACSignal {
        checked = true

        return RACSignal.empty()
    }
}
