import Quick
import Nimble
@testable
import Kiosk
import RxSwift
import Nimble_Snapshots
import Foundation
import Moya

class ListingsViewControllerConfiguration: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("a listings controller") { (sharedExampleContext: SharedExampleContext) in
            var subject: ListingsViewController!
            var viewModel: ListingsViewControllerTestsStubbedViewModel!

            beforeEach{
                subject = sharedExampleContext()["subject"] as! ListingsViewController
                viewModel = subject.viewModel as! ListingsViewControllerTestsStubbedViewModel
                subject.loadViewProgrammatically()
            }

            it("grid") {
                subject.switchView[0]?.sendActionsForControlEvents(.TouchUpInside)
                expect(subject) == snapshot()
            }
            
            it("least bids") {
                subject.switchView[1]?.sendActionsForControlEvents(.TouchUpInside)
                viewModel.gridSelected.value = false
                expect(subject) == snapshot()
            }

            it("most bids") {
                subject.switchView[2]?.sendActionsForControlEvents(.TouchUpInside)
                viewModel.gridSelected.value = false
                expect(subject) == snapshot()
            }

            it("highest bid") {
                subject.switchView[3]?.sendActionsForControlEvents(.TouchUpInside)
                viewModel.gridSelected.value = false
                expect(subject) == snapshot()
            }

            it("lowest bid") {
                subject.switchView[4]?.sendActionsForControlEvents(.TouchUpInside)
                viewModel.gridSelected.value = false
                expect(subject) == snapshot()
            }

            it("alphabetical") {
                subject.switchView[5]?.sendActionsForControlEvents(.TouchUpInside)
                viewModel.gridSelected.value = false
                expect(subject) == snapshot()
            }
        }
    }
}

class ListingsViewControllerTests: QuickSpec {
    override func spec() {

        describe("when displaying stubbed contents") {

            var subject: ListingsViewController!

            beforeEach {
                subject = testListingsViewController()
            }

            describe("without lot numbers") {
                itBehavesLike("a listings controller") { ["subject": subject] }
            }

            describe("with lot numbers") {
                beforeEach {
                    let viewModel = ListingsViewControllerTestsStubbedViewModel()
                    viewModel.lotNumber = 13
                    subject.viewModel = viewModel
                }

                itBehavesLike("a listings controller") { ["subject": subject] }
            }

            describe("with artworks not for sale") {
                beforeEach {
                    let viewModel = ListingsViewControllerTestsStubbedViewModel()
                    viewModel.soldStatus = "sold"
                    subject.viewModel = viewModel
                }

                itBehavesLike("a listings controller") { ["subject": subject] }
            }
        }
    }
}

let listingsViewControllerTestsImage = UIImage.testImage(named: "artwork", ofType: "jpg")

func testListingsViewController(storyboard: UIStoryboard = auctionStoryboard) -> ListingsViewController {
    let subject = ListingsViewController.instantiateFromStoryboard(storyboard)
    subject.viewModel = ListingsViewControllerTestsStubbedViewModel()
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

class ListingsViewControllerTestsStubbedViewModel: NSObject, ListingsViewModelType {

    var auctionID = "los-angeles-modern-auctions-march-2015"
    var syncInterval = SyncInterval
    var pageSize = 10
    var logSync: (NSDate) -> Void = { _ in}
    var numberOfSaleArtworks = 10

    var showSpinnerSignal: Observable<Bool>! = just(false)
    var gridSelectedSignal: Observable<Bool>! {
        return gridSelected.asObservable()
    }
    var updatedContentsSignal: Observable<NSDate> {
        return just(NSDate())
    }

    var scheduleOnBackground: (signal: Observable<AnyObject>) -> Observable<AnyObject> = { signal in return signal }
    var scheduleOnForeground: (signal: Observable<[SaleArtwork]>) -> Observable<[SaleArtwork]> = { signal in return signal }

    func saleArtworkViewModelAtIndexPath(indexPath: NSIndexPath) -> SaleArtworkViewModel {
        let saleArtwork = testSaleArtwork()

        saleArtwork.lotNumber = lotNumber
        if let soldStatus = soldStatus {
            saleArtwork.artwork.soldStatus = soldStatus
        }

        saleArtwork.openingBidCents = 1_000_00 * (indexPath.item + 1)

        return saleArtwork.viewModel
    }

    func showDetailsForSaleArtworkAtIndexPath(indexPath: NSIndexPath) { }

    func presentModalForSaleArtworkAtIndexPath(indexPath: NSIndexPath) { }
    func imageAspectRatioForSaleArtworkAtIndexPath(indexPath: NSIndexPath) -> CGFloat? { return nil }

    // Testing values
    var lotNumber: Int?
    var soldStatus: String?
    var gridSelected = Variable(true)
}
