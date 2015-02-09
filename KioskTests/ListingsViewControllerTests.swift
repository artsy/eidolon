import Quick
import Nimble
import Kiosk
import ReactiveCocoa
import Nimble_Snapshots
import SDWebImage
import Moya

class ListingsViewControllerConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("a listings controller", { (sharedExampleContext: SharedExampleContext) in
            var sut: ListingsViewController!

            beforeEach{
                sut = sharedExampleContext()["sut"] as ListingsViewController!
            }

            it("grid") {
                sut.switchView[0]?.sendActionsForControlEvents(.TouchUpInside)
                expect(sut) == snapshot()
            }
            it("least bids") {
                sut.switchView[1]?.sendActionsForControlEvents(.TouchUpInside)
                expect(sut) == snapshot()
            }

            it("most bids") {
                sut.switchView[2]?.sendActionsForControlEvents(.TouchUpInside)
                expect(sut) == snapshot()
            }

            it("highest bid") {
                sut.switchView[3]?.sendActionsForControlEvents(.TouchUpInside)
                expect(sut) == snapshot()
            }

            it("lowest bid") {
                sut.switchView[4]?.sendActionsForControlEvents(.TouchUpInside)
                expect(sut) == snapshot()
            }

            it("alphabetical") {
                sut.switchView[5]?.sendActionsForControlEvents(.TouchUpInside)
                expect(sut) == snapshot()
            }
        })
    }
}

class ListingsViewControllerTests: QuickSpec {
    let imageCache = SDImageCache.sharedImageCache()
    override func spec() {
        beforeEach {
            Provider.sharedProvider = Provider.StubbingProvider()
            
            let image = UIImage.testImage(named: "artwork", ofType: "jpg")
            
            let urls = [
                "http://stagic3.artsy.net/additional_images/527c19f7a09a677dea000374/large.jpg",
                "http://stagic1.artsy.net/additional_images/52570f80275b24468c000506/large.jpg",
                "http://stagic1.artsy.net/additional_images/5277e3e4cd530eb866000260/1/large.jpg",
                "http://stagic2.artsy.net/additional_images/5277f91dc9dc242b0a000156/1/large.jpg",
                "http://stagic3.artsy.net/additional_images/526ab701c9dc24668f00011e/large.jpg"
            ]
            urls.map { self.imageCache.storeImage(image, forKey: $0) }
        }
        
        afterEach {
            self.imageCache.clearMemory()
            self.imageCache.clearDisk()
        }
        
        describe("when displaying stubbed contents") {
            var sut: ListingsViewController!
            beforeEach {
                sut = testListingsViewController()
                sut.loadViewProgrammatically()
            }

            describe("without lot numbers") {
                itBehavesLike("a listings controller") { ["sut": sut] }
            }

            describe("with lot numbers") {
                beforeEach {
                    sut.beginAppearanceTransition(true, animated: false)
                    sut.endAppearanceTransition()
                    sut.saleArtworks.map { $0.lotNumber = 13 }
                }
                itBehavesLike("a listings controller") { ["sut": sut] }
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
                let sut = testListingsViewController()
                sut.pageSize = 2
                
                sut.beginAppearanceTransition(true, animated: false)
                sut.endAppearanceTransition()
                
                let numberOfSaleArtworks = countElements(sut.saleArtworks)
                expect(numberOfSaleArtworks) == 3
            }
            
            it("updates with new values in existing sale artworks") {
                let sut = testListingsViewController()
                sut.syncInterval = 1
                
                sut.beginAppearanceTransition(true, animated: false)
                sut.endAppearanceTransition()
                
                let firstSale = sut.saleArtworks[0]
                expect(sut.saleArtworks[0].bidCount) == initialBidCount
                
                bidCount = finalBidCount
                expect(sut.saleArtworks[0].bidCount).toEventually(equal(finalBidCount), timeout: 3, pollInterval: 0.6)
            }
            
            it("updates with new sale artworks when lengths differ") {
                let sut = testListingsViewController()
                sut.syncInterval = 1
                
                sut.beginAppearanceTransition(true, animated: false)
                sut.endAppearanceTransition()
                
                count = 2
                expect(countElements(sut.saleArtworks)) == 2
                
                count = 5
                expect(countElements(sut.saleArtworks)).toEventually(equal(5), timeout: 3, pollInterval: 0.6)
            }
        }
    }
}

let testSchedule = { (signal: RACSignal, scheduler: RACScheduler) -> RACSignal in
    // Tricks the sut to thinking it's been scheduled on another queue
    return signal
}

func testListingsViewController(storyboard: UIStoryboard = auctionStoryboard) -> ListingsViewController {
    let sut = ListingsViewController.instantiateFromStoryboard(storyboard)
    sut.schedule = testSchedule
    sut.auctionID = ""
    sut.switchView.shouldAnimate = false
    sut.forceSync = true
    
    return sut
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
