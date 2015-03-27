import Quick
import Nimble
import Kiosk
import ReactiveCocoa
import Nimble_Snapshots
import Moya

class ListingsViewControllerConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("a listings controller", { (sharedExampleContext: SharedExampleContext) in
            var subject: ListingsViewController!

            beforeEach{
                subject = sharedExampleContext()["subject"] as ListingsViewController!
            }

            it("grid") {
                subject.switchView[0]?.sendActionsForControlEvents(.TouchUpInside)
                expect(subject) == snapshot()
            }
            
            it("least bids") {
                subject.switchView[1]?.sendActionsForControlEvents(.TouchUpInside)
                expect(subject) == snapshot()
            }

            it("most bids") {
                subject.switchView[2]?.sendActionsForControlEvents(.TouchUpInside)
                expect(subject) == snapshot()
            }

            it("highest bid") {
                subject.switchView[3]?.sendActionsForControlEvents(.TouchUpInside)
                expect(subject) == snapshot()
            }

            it("lowest bid") {
                subject.switchView[4]?.sendActionsForControlEvents(.TouchUpInside)
                expect(subject) == snapshot()
            }

            it("alphabetical") {
                subject.switchView[5]?.sendActionsForControlEvents(.TouchUpInside)
                expect(subject) == snapshot()
            }
        })
    }
}

class ListingsViewControllerTests: QuickSpec {
    override func spec() {
        beforeEach {
            Provider.sharedProvider = Provider.StubbingProvider()
        }

        describe("when displaying stubbed contents") {
            var subject: ListingsViewController!
            beforeEach {
                subject = testListingsViewController()
                subject.loadViewProgrammatically()
            }

            describe("without lot numbers") {
                itBehavesLike("a listings controller") { ["subject": subject] }
            }

            describe("with lot numbers") {
                beforeEach {
                    subject.beginAppearanceTransition(true, animated: false)
                    subject.endAppearanceTransition()
                    subject.saleArtworks.map { $0.lotNumber = 13 }
                }
                itBehavesLike("a listings controller") { ["subject": subject] }
            }
        }
        
        describe("syncing") {
            let initialBidCount = 3
            let finalBidCount = 5
            
            var bidCount = initialBidCount
            var count: Int?
            
            beforeEach {
                bidCount = initialBidCount
                count = nil
                
                let endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
                    
                    switch target {
                    case ArtsyAPI.AuctionListings:
                        if let page = parameters["page"] as? Int {
                            return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, listingsDataForPage(page, bidCount, count)), method: method, parameters: parameters)
                        } else {
                            return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)
                        }
                    default:
                        return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)
                    }
                }
                
                Provider.sharedProvider = ReactiveMoyaProvider(endpointsClosure: endpointsClosure, endpointResolver: endpointResolver(), stubResponses: true)
            }
            
            it("paginates to the second page to retrieve all three sale artworks") {
                let subject = testListingsViewController()
                subject.pageSize = 2
                
                subject.beginAppearanceTransition(true, animated: false)
                subject.endAppearanceTransition()
                
                let numberOfSaleArtworks = countElements(subject.saleArtworks)
                expect(numberOfSaleArtworks) == 3
            }
            
            it("updates with new values in existing sale artworks") {
                let subject = testListingsViewController()
                subject.syncInterval = 1
                
                subject.beginAppearanceTransition(true, animated: false)
                subject.endAppearanceTransition()
                
                let firstSale = subject.saleArtworks[0]
                expect(subject.saleArtworks[0].bidCount) == initialBidCount
                
                bidCount = finalBidCount
                expect(subject.saleArtworks[0].bidCount).toEventually(equal(finalBidCount), timeout: 3, pollInterval: 0.6)
            }
            
            it("updates with new sale artworks when lengths differ") {
                let subject = testListingsViewController()
                subject.syncInterval = 1
                
                subject.beginAppearanceTransition(true, animated: false)
                subject.endAppearanceTransition()
                
                count = 2
                expect(countElements(subject.saleArtworks)) == 2
                
                count = 5
                expect(countElements(subject.saleArtworks)).toEventually(equal(5), timeout: 3, pollInterval: 0.6)
            }
        }
    }
}

let testSchedule = { (signal: RACSignal, scheduler: RACScheduler) -> RACSignal in
    // Tricks the subject to thinking it's been scheduled on another queue
    return signal
}

let listingsViewControllerTestsImage = UIImage.testImage(named: "artwork", ofType: "jpg")

func testListingsViewController(storyboard: UIStoryboard = auctionStoryboard) -> ListingsViewController {
    let subject = ListingsViewController.instantiateFromStoryboard(storyboard)
    subject.schedule = testSchedule
    subject.auctionID = ""
    subject.switchView.shouldAnimate = false
    subject.logSync = { _ -> () in  }
    subject.downloadImage = { (url, imageView) -> () in
        if let _ = url {
            imageView.image = listingsViewControllerTestsImage
        } else {
            imageView.image = nil
        }
    }
    subject.cancelDownloadImage = { (imageView) -> () in }
    
    return subject
}

func listingsDataForPage(page: Int, bidCount: Int, _count: Int?) -> NSData {
    var count = page == 1 ? 2 : 1
    if _count != nil {
        count = _count!
    }
    
    let models = Array<Int>(1...count).reduce(NSArray(), combine: { (memo: NSArray, page: Int) -> NSArray in
        let model = [
            "id": "\(count+page*10)",
            "artwork": [
                "id": "artwork-id",
                "title": "artwork title",
                "date": "late 2014",
                "blurb": "Some description",
                "price": "1200"
            ],
            "bidder_positions_count": bidCount
        ]
        return memo.arrayByAddingObject(model)
    })
    
    return NSJSONSerialization.dataWithJSONObject(models, options: nil, error: nil)!
}
