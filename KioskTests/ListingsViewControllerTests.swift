import Quick
import Nimble
@testable
import Kiosk
import RxSwift
import Nimble_Snapshots
import Foundation
import Moya

class ListingsViewControllerConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("a listings controller") { (sharedExampleContext: @escaping SharedExampleContext) in
            var subject: ListingsViewController!
            var viewModel: ListingsViewControllerTestsStubbedViewModel!

            beforeEach{
                subject = sharedExampleContext()["subject"] as! ListingsViewController
                viewModel = subject.viewModel as! ListingsViewControllerTestsStubbedViewModel
                subject.loadViewProgrammatically()
            }

            it("grid") {
                subject.switchView[0]?.sendActions(for: .touchUpInside)
                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }
            
            it("least bids") {
                subject.switchView[1]?.sendActions(for: .touchUpInside)
                viewModel._gridSelected.value = false
                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }

            it("most bids") {
                subject.switchView[2]?.sendActions(for: .touchUpInside)
                viewModel._gridSelected.value = false
                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }

            it("highest bid") {
                subject.switchView[3]?.sendActions(for: .touchUpInside)
                viewModel._gridSelected.value = false
                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }

            it("lowest bid") {
                subject.switchView[4]?.sendActions(for: .touchUpInside)
                viewModel._gridSelected.value = false
                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
            }

            it("alphabetical") {
                subject.switchView[5]?.sendActions(for: .touchUpInside)
                viewModel._gridSelected.value = false
                expect(subject).to( haveValidSnapshot(usesDrawRect: true) )
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
    var logSync: (Date) -> Void = { _ in}
    var numberOfSaleArtworks = 10

    var showSpinner: Observable<Bool>! = Observable.just(false)
    var gridSelected: Observable<Bool>! {
        return _gridSelected.asObservable()
    }
    var updatedContents: Observable<NSDate> {
        return Observable.just(NSDate())
    }

    var scheduleOnBackground: (_ observable: Observable<Any>) -> Observable<Any> = { observable in observable }
    var scheduleOnForeground: (_ observable: Observable<[SaleArtwork]>) -> Observable<[SaleArtwork]> = { observable in observable }

    func saleArtworkViewModel(atIndexPath indexPath: IndexPath) -> SaleArtworkViewModel {
        let saleArtwork = testSaleArtwork()

        saleArtwork.lotNumber = lotNumber as NSNumber?
        if let soldStatus = soldStatus {
            saleArtwork.artwork.soldStatus = soldStatus
        }

        saleArtwork.openingBidCents = (1_000_00 * (indexPath.item + 1)) as NSNumber

        return saleArtwork.viewModel
    }

    func showDetailsForSaleArtwork(atIndexPath indexPath: IndexPath) { }

    func presentModalForSaleArtwork(atIndexPath indexPath: IndexPath) { }
    func imageAspectRatioForSaleArtwork(atIndexPath indexPath: IndexPath) -> CGFloat? { return nil }

    // Testing values
    var lotNumber: Int?
    var soldStatus: String?
    var _gridSelected = Variable(true)
}
