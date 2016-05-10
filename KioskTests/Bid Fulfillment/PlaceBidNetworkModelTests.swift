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
        var authorizedNetworking: AuthorizedNetworking!

        beforeEach {
            fulfillmentController = StubFulfillmentController()
            subject = PlaceBidNetworkModel(bidDetails: fulfillmentController.bidDetails)
            disposeBag = DisposeBag()
            authorizedNetworking = Networking.newAuthorizedStubbingNetworking()
        }

        it("maps good responses to observable completions") {
            var completed = false

            waitUntil { done in
                subject
                    .bid(authorizedNetworking)
                    .subscribeCompleted {
                        completed = true
                        done()
                    }
                    .addDisposableTo(disposeBag)
            }

            expect(completed).to( beTrue() )
        }

        it("maps good responses to bidder positions") {
            var bidderPositionID: String?
            waitUntil { done in
                subject
                    .bid(authorizedNetworking)
                    .subscribeNext { id in
                        bidderPositionID = id
                        done()
                    }
                    .addDisposableTo(disposeBag)
            }

            // ID retrieved from CreateABid.json
            expect(bidderPositionID) == "5437dd107261692daa170000"
        }

        it("maps bid details into a proper request") {
            var auctionID: String?
            var artworkID: String?
            var bidCents: String?

            let provider = OnlineProvider(endpointClosure: { target -> (Endpoint<ArtsyAuthenticatedAPI>) in
                if case .PlaceABid(let receivedAuctionID, let receivedArtworkID, let receivedBidCents) = target {
                    auctionID = receivedAuctionID
                    artworkID = receivedArtworkID
                    bidCents = receivedBidCents
                }

                let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
                return Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(200, stubbedResponse("CreateABid"))}, method: target.method, parameters: target.parameters)
                }, stubClosure: MoyaProvider.ImmediatelyStub, online: Observable.just(true))



            waitUntil { done in
                subject
                    .bid(AuthorizedNetworking(provider: provider))
                    .subscribeCompleted {
                        done()
                    }
                    .addDisposableTo(disposeBag)
            }
            
            expect(auctionID) == (fulfillmentController.bidDetails.saleArtwork?.auctionID)!
            expect(artworkID) == fulfillmentController.bidDetails.saleArtwork!.artwork.id
            expect(Int(bidCents!)) == Int(fulfillmentController.bidDetails.bidAmountCents.value ?? 0)
        }

        describe("failing network responses") {
            var networking: AuthorizedNetworking!

            beforeEach {
                let provider = OnlineProvider(endpointClosure: { target -> (Endpoint<ArtsyAuthenticatedAPI>) in
                    let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
                    return Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(400, stubbedResponse("CreateABidFail"))}, method: target.method, parameters: target.parameters)
                    }, stubClosure: MoyaProvider.ImmediatelyStub, online: Observable.just(true))

                networking = AuthorizedNetworking(provider: provider)
            }

            it("maps failures due to outbidding to correct error types") {
                var error: NSError?
                waitUntil { done in
                    subject
                        .bid(networking)
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
                        .bid(networking)
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