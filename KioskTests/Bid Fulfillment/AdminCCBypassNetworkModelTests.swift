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
            let networking = networkingForBidder(createdByAdmin: nil) // nil indicates not registered to bid.

            var receivedResult: BypassResult?
            waitUntil { done in
                subject
                    .checkForAdminCCBypass("the-fun-sale", authorizedNetworking: networking)
                    .subscribe(onNext: { result in
                        receivedResult = result
                        done()
                    })
                    .addDisposableTo(disposeBag)
            }

            // We need to use their providers because Nimble doesn't like comparing struct instances.
            expect(receivedResult) == .requireCC
        }

        it("handles bidders created by admins") {
            let networking = networkingForBidder(createdByAdmin: true)

            var receivedResult: BypassResult?
            waitUntil { done in
                subject
                    .checkForAdminCCBypass("the-fun-sale", authorizedNetworking: networking)
                    .subscribe(onNext: { result in
                        receivedResult = result
                        done()
                    })
                    .addDisposableTo(disposeBag)
            }

            // We need to use their providers because Nimble doesn't like comparing struct instances.
            expect(receivedResult) == .skipCCRequirement
        }

        it("handles bidders not created by admins") {
            let networking = networkingForBidder(createdByAdmin: false)

            var receivedResult: BypassResult?
            waitUntil { done in
                subject
                    .checkForAdminCCBypass("the-fun-sale", authorizedNetworking: networking)
                    .subscribe(onNext: { result in
                        receivedResult = result
                        done()
                    })
                    .addDisposableTo(disposeBag)
            }

            // We need to use their providers because Nimble doesn't like comparing struct instances.
            expect(receivedResult) == .requireCC
        }
    }
}

private func networkingForBidder(createdByAdmin: Bool?) -> AuthorizedNetworking {
    let sampleData: Data

    if let createdByAdmin = createdByAdmin {
        let dictionary = [
            "id" : "thebestbidderever",
            "saleID" : "the-best-sale-in-the-world",
            "created_by_admin": createdByAdmin,
            "ping": "1234"
        ] as [String : Any]

        sampleData = try! JSONSerialization.data(withJSONObject: [dictionary], options: [])
    } else {
        // nil represents no bidder, so we'll return an empty array.
        sampleData = try! JSONSerialization.data(withJSONObject: [], options: [])
    }

    let provider = OnlineProvider<ArtsyAuthenticatedAPI>(endpointClosure: { target in
            return Endpoint(url: "oaishdf", sampleResponseClosure: {.networkResponse(200, sampleData)})
        },
        stubClosure: MoyaProvider.immediatelyStub,
        online: .just(true))

    let networking = AuthorizedNetworking(provider: provider)
    return networking
}
