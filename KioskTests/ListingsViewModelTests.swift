import Quick
import Nimble
import RxSwift
import Moya
@testable
import Kiosk

let testScheduleOnBackground: (_ observable: Observable<Any>) -> Observable<Any> = { observable in observable }
let testScheduleOnForeground: (_ observable: Observable<[SaleArtwork]>) -> Observable<[SaleArtwork]> = { observable in observable }

class ListingsViewModelTests: QuickSpec {
    override func spec() {
        var subject: ListingsViewModel!

        let initialBidCount = 3
        let finalBidCount = 5

        var bidCount: Int!
        var saleArtworksCount: Int?
        var provider: Networking!

        var disposeBag: DisposeBag!

        beforeEach {
            bidCount = initialBidCount

            saleArtworksCount = nil

            let endpointsClosure: MoyaProvider<ArtsyAPI>.EndpointClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
                switch target {
                case ArtsyAPI.auctionListings:
                    if let page = target.parameters!["page"] as? Int {
                        return Endpoint<ArtsyAPI>(url: url(target), sampleResponseClosure: {.networkResponse(200, listingsData(forPage: page, bidCount: bidCount, modelCount: saleArtworksCount))}, method: target.method, parameters: target.parameters)
                    } else {
                        return Endpoint<ArtsyAPI>(url: url(target), sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
                    }
                default:
                    return Endpoint<ArtsyAPI>(url: url(target), sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
                }
            }

            provider = Networking(provider: OnlineProvider(endpointClosure: endpointsClosure, stubClosure: MoyaProvider.immediatelyStub, online: Observable.just(true)))

            disposeBag = DisposeBag()
        }

        afterEach {
            // Force subject to deallocate and stop syncing.
            subject = nil
        }


        it("paginates to the second page to retrieve all three sale artworks") {

            subject = ListingsViewModel(provider: provider, selectedIndex: Observable.just(0), showDetails: { _ in }, presentModal: { _ in }, pageSize: 2, logSync: { _ in}, scheduleOnBackground: testScheduleOnBackground, scheduleOnForeground: testScheduleOnForeground)

            waitUntil { done in
                subject.updatedContents.take(1).subscribe(onCompleted: {
                    done()
                }).addDisposableTo(disposeBag)
            }

            expect(subject.numberOfSaleArtworks) == 3
        }

        it("updates with new values in existing sale artworks") {
            subject = ListingsViewModel(provider: provider, selectedIndex: Observable.just(0), showDetails: { _ in }, presentModal: { _ in }, pageSize: 2, syncInterval: 1, logSync: { _ in}, scheduleOnBackground: testScheduleOnBackground, scheduleOnForeground: testScheduleOnForeground)

            // Verify that initial value is correct
            waitUntil(timeout: 5) { done in
                subject.updatedContents.take(1).flatMap { _ in
                    return subject.saleArtworkViewModel(atIndexPath: IndexPath(item: 0, section: 0)).numberOfBids().take(1)
                }.subscribe(onNext: { string in
                    expect(string) == "\(initialBidCount) bids placed"
                    done()
                }).addDisposableTo(disposeBag)
            }

            // Simulate update from API, wait for sync to happen
            bidCount = finalBidCount

            waitUntil(timeout: 5) { done in
                // We skip 1 to avoid getting the existing value, and wait for the updated one when the subject syncs.
                subject.saleArtworkViewModel(atIndexPath: IndexPath(item: 0, section: 0)).numberOfBids().skip(1).subscribe(onNext: { string in
                    expect(string) == "\(finalBidCount) bids placed"
                    done()
                }).addDisposableTo(disposeBag)
            }
        }

        it("updates with new sale artworks when lengths differ") {
            let subject = ListingsViewModel(provider: provider, selectedIndex: Observable.just(0), showDetails: { _ in }, presentModal: { _ in }, syncInterval: 1, logSync: { _ in}, scheduleOnBackground: testScheduleOnBackground, scheduleOnForeground: testScheduleOnForeground)

            saleArtworksCount = 2

            // Verify that initial value is correct
            waitUntil(timeout: 5) { done in
                subject.updatedContents.take(1).subscribe(onCompleted: {
                    expect(subject.numberOfSaleArtworks) == 2
                    done()
                }).addDisposableTo(disposeBag)
            }

            // Simulate update from API, wait for sync to happen
            saleArtworksCount = 5

            // Verify that initial value is correct
            waitUntil(timeout: 5) { done in
                subject.updatedContents.skip(1).take(1).subscribe(onCompleted: {
                    expect(subject.numberOfSaleArtworks) == 5
                    done()
                }).addDisposableTo(disposeBag)
            }
        }

        it("syncs correctly even if lot numbers have changed") {
            var reverseIDs = false

            let endpointsClosure: MoyaProvider<ArtsyAPI>.EndpointClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
                switch target {
                case ArtsyAPI.auctionListings:
                    return Endpoint<ArtsyAPI>(url: url(target), sampleResponseClosure: {.networkResponse(200, listingsData(forPage: 1, bidCount: 0, modelCount: 3, reverseIDs: reverseIDs))}, method: target.method, parameters: target.parameters)
                default:
                    return Endpoint<ArtsyAPI>(url: url(target), sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
                }
            }

            let provider = Networking(provider: OnlineProvider(endpointClosure: endpointsClosure, stubClosure: MoyaProvider.immediatelyStub, online: Observable.just(true)))

            subject = ListingsViewModel(provider: provider, selectedIndex: Observable.just(0), showDetails: { _ in }, presentModal: { _ in }, pageSize: 4, syncInterval: 1, logSync: { _ in}, scheduleOnBackground: testScheduleOnBackground, scheduleOnForeground: testScheduleOnForeground)

            var initialFirstLotID: String?
            var subsequentFirstLotID: String?

            // First we get our initial sync
            waitUntil { done in
                subject.updatedContents.take(1).subscribe(onCompleted: {
                    initialFirstLotID = subject.saleArtworkViewModel(atIndexPath: IndexPath(item: 0, section: 0)).saleArtworkID
                    done()
                }).addDisposableTo(disposeBag)
            }

            // Now we reverse the lot numbers
            reverseIDs = true
            waitUntil { done in
                subject.updatedContents.skip(1).take(1).subscribe(onCompleted: {
                    subsequentFirstLotID = subject.saleArtworkViewModel(atIndexPath: IndexPath(item: 0, section: 0)).saleArtworkID
                    done()
                }).addDisposableTo(disposeBag)
            }

            expect(initialFirstLotID).toNot( beEmpty() )
            expect(subsequentFirstLotID).toNot( beEmpty() )

            // Now that the IDs have changed, check that they're not equal.
            expect(initialFirstLotID) != subsequentFirstLotID
        }
    }
}


func listingsData(forPage page: Int, bidCount: Int, modelCount: Int?, reverseIDs: Bool = false) -> Data {
    let count = modelCount ?? (page == 1 ? 2 : 1)

    let models = Array<Int>(1...count).map { index -> NSDictionary in
        return [
            "id": "\(count+page*10 + (reverseIDs ? count - index : index))",
            "artwork": [
                "id": "artwork-id",
                "title": "artwork title",
                "date": "late 2014",
                "blurb": "Some description",
                "price": "1200",
            ],
            "lot_number": index,
            "bidder_positions_count": bidCount
        ]
    }

    return try! JSONSerialization.data(withJSONObject: models, options: [])
}
