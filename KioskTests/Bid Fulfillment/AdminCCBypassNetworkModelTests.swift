import Quick
import Nimble
import RxSwift
import Moya
@testable
import Kiosk

class AdminCCBypassNetworkModelTests: QuickSpec {
    override func spec() {
        var subject: AdminCCBypassNetworkModel!
        var disposeBag: DisposeBag!

        beforeEach {
            subject = AdminCCBypassNetworkModel()
            disposeBag = DisposeBag()
        }

        it("handles unregistered bidders") {
            let networking = networkingForBidderCreatedByAdmin(nil) // nil indicates not registered to bid.

            var receivedResult: BypassResult?
            waitUntil { done in
                subject
                    .checkForAdminCCBypass("the-fun-sale", authorizedNetworking: networking)
                    .subscribeNext { result in
                        receivedResult = result
                        done()
                    }
                    .addDisposableTo(disposeBag)
            }

            // We need to use their providers because Nimble doesn't like comparing struct instances.
            expect(receivedResult) == .RequireCC
        }

        it("handles bidders created by admins") {
            let networking = networkingForBidderCreatedByAdmin(true)

            var receivedResult: BypassResult?
            waitUntil { done in
                subject
                    .checkForAdminCCBypass("the-fun-sale", authorizedNetworking: networking)
                    .subscribeNext { result in
                        receivedResult = result
                        done()
                    }
                    .addDisposableTo(disposeBag)
            }

            // We need to use their providers because Nimble doesn't like comparing struct instances.
            expect(receivedResult) == .SkipCCRequirement
        }

        it("handles bidders not created by admins") {
            let networking = networkingForBidderCreatedByAdmin(false)

            var receivedResult: BypassResult?
            waitUntil { done in
                subject
                    .checkForAdminCCBypass("the-fun-sale", authorizedNetworking: networking)
                    .subscribeNext { result in
                        receivedResult = result
                        done()
                    }
                    .addDisposableTo(disposeBag)
            }

            // We need to use their providers because Nimble doesn't like comparing struct instances.
            expect(receivedResult) == .RequireCC
        }
    }
}

private func networkingForBidderCreatedByAdmin(createdByAdmin: Bool?) -> AuthorizedNetworking {
    let sampleData: NSData

    if let createdByAdmin = createdByAdmin {
        let dictionary = [
            "id" : "thebestbidderever",
            "saleID" : "the-best-sale-in-the-world",
            "created_by_admin": createdByAdmin,
            "ping": "1234"
        ]

        sampleData = try! NSJSONSerialization.dataWithJSONObject([dictionary], options: [])
    } else {
        // nil represents no bidder, so we'll return an empty array.
        sampleData = try! NSJSONSerialization.dataWithJSONObject([], options: [])
    }

    let provider = OnlineProvider<ArtsyAuthenticatedAPI>(endpointClosure: { target in
            return Endpoint(URL: "oaishdf", sampleResponseClosure: {.NetworkResponse(200, sampleData)})
        },
        stubClosure: MoyaProvider.ImmediatelyStub,
        online: .just(true))

    let networking = AuthorizedNetworking(provider: provider)
    return networking
}
