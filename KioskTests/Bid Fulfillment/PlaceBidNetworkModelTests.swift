import Quick
import Nimble
import RxSwift
import Moya
@testable
import Kiosk

class PlaceBidNetworkModelTests: QuickSpec {
    override func spec() {
        var fulfillmentController: StubFulfillmentController!
        var subject: PlaceBidNetworkModel!
        var disposeBag: DisposeBag!

        beforeEach {
            fulfillmentController = StubFulfillmentController()
            subject = PlaceBidNetworkModel(fulfillmentController: fulfillmentController)
            disposeBag = DisposeBag()
        }

        it("maps good responses to signal completions") {
            var completed = false

            waitUntil { done in
                subject
                    .bidSignal()
                    .subscribeCompleted {
                        completed = true
                        done()
                    }
                    .addDisposableTo(disposeBag)
            }

            expect(completed).to( beTrue() )
        }

        it("maps good responses to bidder positions") {
            waitUntil { done in
                subject
                    .bidSignal()
                    .subscribeCompleted {
                        done()
                    }
                    .addDisposableTo(disposeBag)
            }

            // ID retrieved from CreateABid.json
            expect(subject.bidderPosition?.id) == "5437dd107261692daa170000"
        }

        it("maps bid details into a proper request") {
            var auctionID: String?
            var artworkID: String?
            var bidCents: String?

            let provider = RxMoyaProvider(endpointClosure: { target -> (Endpoint<ArtsyAPI>) in
                if case .PlaceABid(let receivedAuctionID, let receivedArtworkID, let receivedBidCents) = target {
                    auctionID = receivedAuctionID
                    artworkID = receivedArtworkID
                    bidCents = receivedBidCents
                }

                let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
                return Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(200, stubbedResponse("CreateABid"))}, method: target.method, parameters: target.parameters)
                }, stubClosure: MoyaProvider.ImmediatelyStub)

            fulfillmentController.loggedInProvider = provider


            waitUntil { done in
                subject
                    .bidSignal()
                    .subscribeCompleted {
                        done()
                    }
                    .addDisposableTo(disposeBag)
            }

            expect(auctionID) == fulfillmentController.bidDetails.saleArtwork?.auctionID
            expect(artworkID) == fulfillmentController.bidDetails.saleArtwork?.artwork.id
            expect(Int(bidCents!)) == Int(fulfillmentController.bidDetails.bidAmountCents.value!)
        }

        describe("failing network responses") {

            beforeEach {
                let provider = RxMoyaProvider(endpointClosure: { target -> (Endpoint<ArtsyAPI>) in
                    let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
                    return Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(400, stubbedResponse("CreateABidFail"))}, method: target.method, parameters: target.parameters)
                }, stubClosure: MoyaProvider.ImmediatelyStub)

                fulfillmentController.loggedInProvider = provider
            }

            it("maps failures due to outbidding to correct error types") {
                var error: NSError?
                waitUntil { done in
                    subject
                        .bidSignal()
                        .subscribeError { receivedError in
                            error = receivedError as NSError
                            done()
                        }
                        .addDisposableTo(disposeBag)
                }

                expect(error?.domain) == OutbidDomain
            }

            it("errors on non-200 status codes"){
                var errored = false
                waitUntil { done in
                    subject
                        .bidSignal()
                        .subscribeError { _ in
                            errored = true
                            done()
                        }
                        .addDisposableTo(disposeBag)
                }

                expect(errored).to( beTrue() )
            }
        }
    }
}