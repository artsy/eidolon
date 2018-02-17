import Quick
import Nimble
import RxNimble
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
            subject = LoadingViewModel(provider: Networking.newStubbingNetworking(), bidNetworkModel: stubbedNetworkModel, placingBid: false, actionsComplete: Observable.never())
            expect(subject.placeBidNetworkModel.bidDetails as AnyObject) === subject.bidderNetworkModel.bidDetails as AnyObject
        }

        it("loads bidCheckingModel") {
            subject = LoadingViewModel(provider: Networking.newStubbingNetworking(), bidNetworkModel: stubbedNetworkModel, placingBid: false, actionsComplete: Observable.never())
            expect(subject.bidCheckingModel.bidDetails as AnyObject) === subject.bidderNetworkModel.bidDetails
        }

        it("initializes with bidNetworkModel") {
            let networkModel = StubBidderNetworkModel()
            subject = LoadingViewModel(provider: Networking.newStubbingNetworking(), bidNetworkModel: networkModel, placingBid: false, actionsComplete: Observable.never())

            expect(subject.bidderNetworkModel.bidDetails as AnyObject) === networkModel.bidDetails as AnyObject
        }

        it("initializes with placingBid = false") {
            subject = LoadingViewModel(provider: Networking.newStubbingNetworking(), bidNetworkModel: stubbedNetworkModel, placingBid: false, actionsComplete: Observable.never())

            expect(subject.placingBid) == false
        }

        it("initializes with placingBid = true") {
            subject = LoadingViewModel(provider: Networking.newStubbingNetworking(), bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsComplete: Observable.never())

            expect(subject.placingBid) == true
        }

        it("binds createdNewBidder") {
            subject = LoadingViewModel(provider: Networking.newStubbingNetworking(), bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsComplete: Observable.never())
            stubbedNetworkModel.createdNewBidderSubject.onNext(true)

            expect(subject.createdNewBidder.asObservable()).first == true
        }

        it("binds bidIsResolved") {
            subject = LoadingViewModel(provider: Networking.newStubbingNetworking(), bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsComplete: Observable.never())
            subject.bidCheckingModel.bidIsResolved.value = true

            expect(subject.bidIsResolved.asObservable()).first == true
        }

        it("binds isHighestBidder") {
            subject = LoadingViewModel(provider: Networking.newStubbingNetworking(), bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsComplete: Observable.never())
            subject.bidCheckingModel.isHighestBidder.value = true

            expect(subject.isHighestBidder.asObservable()).first == true
        }

        it("binds reserveNotMet") {
            subject = LoadingViewModel(provider: Networking.newStubbingNetworking(), bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsComplete: Observable.never())
            subject.bidCheckingModel.reserveNotMet.value = true

            expect(subject.reserveNotMet.asObservable()).first == true
        }

        it("infers bidDetals") {
            subject = LoadingViewModel(provider: Networking.newStubbingNetworking(), bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsComplete: Observable.never())
            expect(subject.bidDetails) === subject.bidderNetworkModel.bidDetails
        }

        it("creates a new bidder if necessary") {
            subject = LoadingViewModel(provider: Networking.newStubbingNetworking(), bidNetworkModel: stubbedNetworkModel, placingBid: false, actionsComplete: Observable.never())
            waitUntil { (done) in
                subject.performActions().subscribe(onCompleted: { done() }).disposed(by: disposeBag)
            }

            expect(subject.createdNewBidder.asObservable()).first == true
        }

        describe("stubbed auxillary network models") {
            var stubPlaceBidNetworkModel: StubPlaceBidNetworkModel!
            var stubBidCheckingNetworkModel: StubBidCheckingNetworkModel!

            beforeEach {
                stubPlaceBidNetworkModel = StubPlaceBidNetworkModel()
                stubBidCheckingNetworkModel = StubBidCheckingNetworkModel()

                subject = LoadingViewModel(provider: Networking.newStubbingNetworking(), bidNetworkModel: stubbedNetworkModel, placingBid: true, actionsComplete: Observable.never())

                subject.placeBidNetworkModel = stubPlaceBidNetworkModel
                subject.bidCheckingModel = stubBidCheckingNetworkModel
            }

            it("places a bid if necessary") {
                waitUntil { done in
                    subject.performActions().subscribe(onCompleted: { done() }).disposed(by: disposeBag)
                    return
                }

                expect(stubPlaceBidNetworkModel.hasBid) == true
            }

            it("waits for bid resolution if bid was placed") {
                waitUntil { done in
                    subject.performActions().subscribe(onCompleted: { done() }).disposed(by: disposeBag)
                }

                expect(stubBidCheckingNetworkModel.checked) == true
            }
        }
    }
}

let bidderID = "some-bidder-id"

class StubBidderNetworkModel: BidderNetworkModelType {
    var createdNewBidderSubject = PublishSubject<Bool>()

    var bidDetails: BidDetails = testBidDetails()

    var createdNewUser: Observable<Bool> { return createdNewBidderSubject.asObservable().startWith(false) }

    func createOrGetBidder() -> Observable<AuthorizedNetworking> {
        createdNewBidderSubject.onNext(true)
        return Observable.just(Networking.newAuthorizedStubbingNetworking())
    }
}

class StubPlaceBidNetworkModel: PlaceBidNetworkModelType {
    var hasBid = false

    var bidDetails: BidDetails = testBidDetails()

    func bid(_ provider: AuthorizedNetworking) -> Observable<String> {
        hasBid = true

        return Observable.just(bidderID)
    }
}

class StubBidCheckingNetworkModel: BidCheckingNetworkModelType {
    var checked = false

    var bidIsResolved = Variable(false)
    var isHighestBidder = Variable(false)
    var reserveNotMet = Variable(false)
    var bidDetails: BidDetails = testBidDetails()

    let fulfillmentController: FulfillmentController = StubFulfillmentController()

    func waitForBidResolution (bidderPositionId: String, provider: AuthorizedNetworking) -> Observable<Void> {
        checked = true

        return Observable.empty()
    }
}
