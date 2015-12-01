import Quick
import Nimble
@testable
import Kiosk
import Nimble_Snapshots
import SDWebImage

class SaleArtworkDetailsViewControllerConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("a sale artwork details view controller", closure: { (sharedExampleContext: SharedExampleContext) in
            var subject: SaleArtworkDetailsViewController!

            beforeEach{
                subject = sharedExampleContext()["subject"] as! SaleArtworkDetailsViewController!
            }

            it("looks ok by default") {
                expect(subject) == snapshot()
            }
        })
    }
}

class SaleArtworkDetailsViewControllerTests: QuickSpec {
    let imageCache = SDImageCache.sharedImageCache()
    override func spec() {
        var subject: SaleArtworkDetailsViewController!

        beforeEach {
            Provider.sharedProvider = Provider.StubbingProvider()

            subject = testSaleArtworkViewController()
            subject.allowAnimations = false

            let image = UIImage.testImage(named: "artwork", ofType: "jpg")
            self.imageCache.storeImage(image, forKey: "http://example.com/large.jpg")
        }

        describe("without lot numbers") {
            itBehavesLike("a sale artwork details view controller") { ["subject": subject] }
        }

        describe("with lot numbers") {
            beforeEach {
                subject.saleArtwork.lotNumber = 13
            }

            itBehavesLike("a sale artwork details view controller") { ["subject": subject] }
        }

        describe("with a buyers premium") {
            beforeEach {
                subject.buyersPremium = { BuyersPremium(id: "id", name: "name") }
            }

            itBehavesLike("a sale artwork details view controller") { ["subject": subject] }
        }

        describe("with an artwork not for sale") {
            beforeEach {
                subject.saleArtwork.artwork.soldStatus = "sold"
            }

            itBehavesLike("a sale artwork details view controller") { ["subject": subject] }
        }
    }
}

func testSaleArtworkViewController(storyboard: UIStoryboard = auctionStoryboard, saleArtwork: SaleArtwork = testSaleArtwork()) -> SaleArtworkDetailsViewController {
    let subject = SaleArtworkDetailsViewController.instantiateFromStoryboard(storyboard)
    subject.saleArtwork = saleArtwork
    subject.buyersPremium = { nil }

    return subject
}
