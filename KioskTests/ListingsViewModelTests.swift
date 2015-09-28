import Quick
import Nimble
import ReactiveCocoa
import Moya
@testable
import Kiosk

class ListingsViewModelTests: QuickSpec {
    override func spec() {
        var subject: ListingsViewModel!

        let initialBidCount = 3
        let finalBidCount = 5

        var bidCount: Int!
        var saleArtworksCount: Int?

        beforeEach { () -> () in
            bidCount = initialBidCount

            saleArtworksCount = nil

            let endpointsClosure: MoyaProvider<ArtsyAPI>.MoyaEndpointsClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
                switch target {
                case ArtsyAPI.AuctionListings:
                    if let page = target.parameters["page"] as? Int {
                        return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, {listingsDataForPage(page, bidCount: bidCount, modelCount: saleArtworksCount)}), method: target.method, parameters: target.parameters)
                    } else {
                        return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, {target.sampleData}), method: target.method, parameters: target.parameters)
                    }
                default:
                    return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, {target.sampleData}), method: target.method, parameters: target.parameters)
                }
            }

            Provider.sharedProvider = ArtsyProvider(endpointClosure: endpointsClosure, stubBehavior: MoyaProvider.ImmediateStubbingBehaviour, onlineSignal: { RACSignal.empty() })
        }

        afterEach { () -> () in
            // Reset for other tests
            Provider.sharedProvider = Provider.StubbingProvider()

            // Force subject to deallocate and stop syncing.
            subject = nil
        }


        it("paginates to the second page to retrieve all three sale artworks") {
            subject = ListingsViewModel(selectedIndexSignal: RACSignal.`return`(0), showDetails: { _ in }, presentModal: { _ in }, pageSize: 2, logSync: { _ in})

            kioskWaitUntil { done -> Void in
                subject.updatedContentsSignal.take(1).subscribeCompleted {
                    done()
                }
            }

            expect(subject.numberOfSaleArtworks) == 3
        }

        it("updates with new values in existing sale artworks") {
            subject = ListingsViewModel(selectedIndexSignal: RACSignal.`return`(0), showDetails: { _ in }, presentModal: { _ in }, syncInterval: 1, logSync: { _ in}, schedule: { signal, _ -> RACSignal in return signal })

            // Verify that initial value is correct
            waitUntil(timeout: 5) { done -> Void in
                subject.updatedContentsSignal.take(1).then {
                    return subject.saleArtworkViewModelAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)).numberOfBidsSignal.take(1)
                }.subscribeNext { string -> Void in
                    expect(string as? String) == "\(initialBidCount) bids placed"
                    done()
                }
            }

            // Simulate update from API, wait for sync to happen
            bidCount = finalBidCount

            waitUntil(timeout: 5) { done -> Void in
                // We skip 1 to avoid getting the existing value, and wait for the updated one when the subject syncs.
                subject.saleArtworkViewModelAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)).numberOfBidsSignal.skip(1).subscribeNext { string -> Void in
                    expect(string as? String) == "\(finalBidCount) bids placed"
                    done()
                }
            }
        }

        it("updates with new sale artworks when lengths differ") {
            let subject = ListingsViewModel(selectedIndexSignal: RACSignal.`return`(0), showDetails: { _ in }, presentModal: { _ in }, syncInterval: 1, logSync: { _ in}, schedule: { signal, _ -> RACSignal in return signal })

            saleArtworksCount = 2

            // Verify that initial value is correct
            waitUntil(timeout: 5) { done -> Void in
                subject.updatedContentsSignal.take(1).subscribeCompleted {
                    expect(subject.numberOfSaleArtworks) == 2
                    done()
                }
            }

            // Simulate update from API, wait for sync to happen
            saleArtworksCount = 5

            // Verify that initial value is correct
            waitUntil(timeout: 5) { done -> Void in
                subject.updatedContentsSignal.skip(1).take(1).subscribeCompleted {
                    expect(subject.numberOfSaleArtworks) == 5
                    done()
                }
            }
        }

        it("syncs correctly even if lot numbers have changed") {
            var reverseIDs = false

            let endpointsClosure: MoyaProvider<ArtsyAPI>.MoyaEndpointsClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
                switch target {
                case ArtsyAPI.AuctionListings:
                    return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, {listingsDataForPage(1, bidCount: 0, modelCount: 3, reverseIDs: reverseIDs)}), method: target.method, parameters: target.parameters)
                default:
                    return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, {target.sampleData}), method: target.method, parameters: target.parameters)
                }
            }

            Provider.sharedProvider = ArtsyProvider(endpointClosure: endpointsClosure, stubBehavior: MoyaProvider.ImmediateStubbingBehaviour, onlineSignal: { RACSignal.empty() })

            subject = ListingsViewModel(selectedIndexSignal: RACSignal.`return`(0), showDetails: { _ in }, presentModal: { _ in }, pageSize: 4, syncInterval: 1, logSync: { _ in})

            var initialFirstLotID: String?
            var subsequentFirstLotID: String?

            // First we get our initial sync
            kioskWaitUntil { done -> Void in
                subject.updatedContentsSignal.take(1).subscribeCompleted {
                    initialFirstLotID = subject.saleArtworkViewModelAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)).saleArtworkID
                    done()
                }
            }

            // Now we reverse the lot numbers
            reverseIDs = true
            kioskWaitUntil { done -> Void in
                subject.updatedContentsSignal.skip(1).take(1).subscribeCompleted {
                    subsequentFirstLotID = subject.saleArtworkViewModelAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)).saleArtworkID
                    done()
                }
            }

            expect(initialFirstLotID).toNot( beEmpty() )
            expect(subsequentFirstLotID).toNot( beEmpty() )

            // Now that the IDs have changed, check that they're not equal.
            expect(initialFirstLotID) != subsequentFirstLotID
        }
    }
}


func listingsDataForPage(page: Int, bidCount: Int, modelCount: Int?, reverseIDs: Bool = false) -> NSData {
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

    return try! NSJSONSerialization.dataWithJSONObject(models, options: [])
}
