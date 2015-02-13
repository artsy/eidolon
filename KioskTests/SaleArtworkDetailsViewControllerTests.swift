import Quick
import Nimble
import Kiosk
import Nimble_Snapshots
import SDWebImage


class SaleArtworkDetailsViewControllerConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("a sale artwork details view controller", { (sharedExampleContext: SharedExampleContext) in
            var sut: SaleArtworkDetailsViewController!

            beforeEach{
                sut = sharedExampleContext()["sut"] as SaleArtworkDetailsViewController!
            }

            it ("looks ok by default") {
                expect(sut) == snapshot()
            }
        })
    }
}

class SaleArtworkDetailsViewControllerTests: QuickSpec {
    let imageCache = SDImageCache.sharedImageCache()
    override func spec() {
        var sut: SaleArtworkDetailsViewController!
        beforeEach {
            Provider.sharedProvider = Provider.StubbingProvider()

            sut = testSaleArtworkViewController()
            sut.allowAnimations = false

            let image = UIImage.testImage(named: "artwork", ofType: "jpg")
            self.imageCache.storeImage(image, forKey: "http://example.com/large.jpg")
        }

        describe("without lot numbers") {
            itBehavesLike("a sale artwork details view controller") { ["sut": sut] }
        }

        describe("with lot numbers") {
            beforeEach {
                sut.saleArtwork.lotNumber = 13
            }

            itBehavesLike("a sale artwork details view controller") { ["sut": sut] }
        }

        describe("with a buyers premium") {
            beforeEach {
                sut.buyersPremium = { BuyersPremium(id: "id", name: "name") }
            }

            itBehavesLike("a sale artwork details view controller") { ["sut": sut] }
        }
    }
}

func testSaleArtworkViewController(storyboard: UIStoryboard = auctionStoryboard, saleArtwork: SaleArtwork = testSaleArtwork()) -> SaleArtworkDetailsViewController {
    let sut = SaleArtworkDetailsViewController.instantiateFromStoryboard(storyboard)
    sut.saleArtwork = saleArtwork
    sut.buyersPremium = { nil }

    return sut
}
