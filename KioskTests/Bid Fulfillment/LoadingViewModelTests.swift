import Quick
import Nimble
@testable
import Kiosk
import RxSwift

class LoadingViewModelTests: QuickSpec {
    override func spec() {
        var stubbedNetworkModel: StubBidderNetworkModel!
        var subject: LoadingViewModel!
        var disposeBag: DisposeBag!

        beforeEach {
            // The subject's reference to its network model is unowned, so we must take responsibility for it.
            stubbedNetworkModel = StubBidderNetworkModel()
            disposeBag = DisposeBag()
        }

        it("loads placeBidNetworkModel") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: false, actionsCompleteSignal: never())
            expect(subject.placeBidNetworkModel.fulfillmentController as AnyObject) === subject.bidderNetworkModel.fulfillmentController as AnyObject
        }

        it("loads bidCheckingModel") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: false, actionsCompleteSignal: never())
            expect(subject.bidCheckingModel.fulfillmentController as AnyObject) === subject.bidderNetworkModel.fulfillmentController
        }

        it("initializes with bidNetworkModel") {
            let networkModel = StubBidderNetworkModel()
            subject = LoadingViewModel(bidNetworkModel: networkModel, placingBid: false, actionsCompleteSignal: never())

            expect(subject.bidderNetworkModel.fulfillmentController as AnyObject) === networkModel.fulfillmentController as AnyObject
        }

        it("initializes with placingBid = false") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: false, actionsCompleteSignal: never())

            expect(subject.placingBid) == false
        }

        it("initializes with placingBid = true") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: never())

            expect(subject.placingBid) == true
        }

        it("binds createdNewBidder") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: never())
            stubbedNetworkModel.createdNewBidderSubject.onNext(true)

            expect(subject.createdNewBidder) == true
        }

        it("binds bidIsResolved") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: never())
            subject.bidCheckingModel.bidIsResolved.value = true

            expect(subject.bidIsResolved) == true
        }

        it("binds isHighestBidder") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: never())
            subject.bidCheckingModel.isHighestBidder.value = true

            expect(subject.isHighestBidder) == true
        }

        it("binds reserveNotMet") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: never())
            subject.bidCheckingModel.reserveNotMet.value = true

            expect(subject.reserveNotMet) == true
        }

        it("infers bidDetals") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: never())
            expect(subject.bidDetails) === subject.bidderNetworkModel.fulfillmentController.bidDetails
        }

        it("creates a new bidder if necessary") {
            subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: false, actionsCompleteSignal: never())
            kioskWaitUntil { (done) in
                subject.performActions().subscribeCompleted { done() }.addDisposableTo(disposeBag)
            }

            expect(subject.createdNewBidder) == true
        }

        describe("stubbed auxillary network models") {
            var stubPlaceBidNetworkModel: StubPlaceBidNetworkModel!
            var stubBidCheckingNetworkModel: StubBidCheckingNetworkModel!

            beforeEach {
                stubPlaceBidNetworkModel = StubPlaceBidNetworkModel()
                stubBidCheckingNetworkModel = StubBidCheckingNetworkModel()

                subject = LoadingViewModel(bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsCompleteSignal: never())

                subject.placeBidNetworkModel = stubPlaceBidNetworkModel
                subject.bidCheckingModel = stubBidCheckingNetworkModel
            }

            it("places a bid if necessary") {
                kioskWaitUntil { done in
                    subject.performActions().subscribeCompleted { done() }.addDisposableTo(disposeBag)
                    return
                }

                expect(stubPlaceBidNetworkModel.bid) == true
            }

            it("waits for bid resolution if bid was placed") {
                kioskWaitUntil { done in
                    subject.performActions().subscribeCompleted { done() }.addDisposableTo(disposeBag)
                }

                expect(stubBidCheckingNetworkModel.checked) == true
            }
        }
    }
}

let bidderID = "some-bidder-id"

class StubBidderNetworkModel: BidderNetworkModelType {
    var createdNewBidderSubject = PublishSubject<Bool>()
    

    let _stubbedFulfillmentController = StubFulfillmentController()
    var fulfillmentController: FulfillmentController { return self._stubbedFulfillmentController }


    var createdNewUser: Observable<Bool> { return createdNewBidderSubject.asObservable().startWith(false) }

    func createOrGetBidder() -> Observable<Void> {
        createdNewBidderSubject.onNext(true)
        return just()
    }
}

class StubPlaceBidNetworkModel: PlaceBidNetworkModelType {
    var bid = false

    let fulfillmentController: FulfillmentController = StubFulfillmentController()

    func bidSignal() -> Observable<String> {
        bid = true

        return just(bidderID)
    }
}

class StubBidCheckingNetworkModel: BidCheckingNetworkModelType {
    var checked = false

    var bidIsResolved = Variable(false)
    var isHighestBidder = Variable(false)
    var reserveNotMet = Variable(false)

    let fulfillmentController: FulfillmentController = StubFulfillmentController()

    func waitForBidResolution (bidderPositionId: String) -> Observable<Void> {
        checked = true

        return empty()
    }
}
