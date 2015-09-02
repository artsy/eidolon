import UIKit
import SystemConfiguration
import ARAnalytics
import ReactiveCocoa
import Swift_RAC_Macros
import ARCollectionViewMasonryLayout

let HorizontalMargins = 65
let VerticalMargins = 26
let MasonryCellIdentifier = "MasonryCell"
let TableCellIdentifier = "TableCell"

class ListingsViewController: UIViewController {
    var allowAnimations = true

    var downloadImage: ListingsCollectionViewCell.DownloadImageClosure = { (url, imageView) -> () in
        if let url = url {
            imageView.sd_setImageWithURL(url)
        } else {
            imageView.image = nil
        }
    }
    var cancelDownloadImage: ListingsCollectionViewCell.CancelDownloadImageClosure = { (imageView) -> () in
        imageView.sd_cancelCurrentImageLoad()
    }

    lazy var viewModel: ListingsViewModelType = {
        return ListingsViewModel(selectedIndexSignal: self.switchView.selectedIndexSignal, showDetails: self.showDetailsForSaleArtwork, presentModal: self.presentModalForSaleArtwork)
    }()

    dynamic var cellIdentifier = MasonryCellIdentifier

    @IBOutlet var stagingFlag: UIImageView!
    @IBOutlet var loadingSpinner: Spinner!
    
    lazy var collectionView: UICollectionView = { return .listingsCollectionViewWithDelegateDatasource(self) }()

    lazy var switchView: SwitchView = {
        return SwitchView(buttonTitles: ListingsViewModel.SwitchValues.allSwitchValueNames())
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up development environment.
        
        if detectDevelopment() {
            let flagImageName = AppSetup.sharedState.useStaging ? "StagingFlag" : "ProductionFlag"
            stagingFlag.image = UIImage(named: flagImageName)
            stagingFlag.hidden = AppSetup.sharedState.isTesting
        } else {
            stagingFlag.hidden = AppSetup.sharedState.useStaging == false
        }
        
        // Add subviews

        view.addSubview(switchView)
        view.insertSubview(collectionView, belowSubview: loadingSpinner)
        
        // Set up reactive bindings

        RAC(self, "loadingSpinner.hidden") <~ viewModel.showSpinnerSignal.not()

        // Map switch selection to cell reuse identifier.
        RAC(self, "cellIdentifier") <~ viewModel.gridSelectedSignal.map { (gridSelected) -> AnyObject! in
            switch gridSelected as? Bool {
            case .Some(true):
                return MasonryCellIdentifier
            default:
                return TableCellIdentifier
            }
        }

        // Reload collection view when there is new content.
        viewModel.updatedContentsSignal.mapReplace(collectionView).doNext { (collectionView) -> Void in
            (collectionView as! UICollectionView).reloadData()
            return
        }.dispatchAsyncMainScheduler().subscribeNext { (collectionView) -> Void in
            // Need to dispatchAsyncMainScheduler, since the changes in the CV's model aren't imediate, so we may scroll to a cell that doesn't exist yet.
            (collectionView as! UICollectionView).scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .Top, animated: false)
        }

        // Respond to changes in layout, driven by switch selection.
        viewModel.gridSelectedSignal.map { [weak self] (gridSelected) -> AnyObject! in
            switch gridSelected as! Bool {
            case true:
                return ListingsViewController.masonryLayout()
            default:
                return ListingsViewController.tableLayout(CGRectGetWidth(self?.switchView.frame ?? CGRectZero))
            }
        }.subscribeNext { [weak self] (layout) -> Void in
            // Need to explicitly call animated: false and reload to avoid animation
            self?.collectionView.setCollectionViewLayout(layout as! UICollectionViewLayout, animated: false)
            return
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .ShowSaleArtworkDetails {
            let saleArtwork = sender as! SaleArtwork!
            let detailsViewController = segue.destinationViewController as! SaleArtworkDetailsViewController
            detailsViewController.saleArtwork = saleArtwork
            ARAnalytics.event("Show Artwork Details", withProperties: ["id": saleArtwork.artwork.id])
        }
    }

    override func viewWillAppear(animated: Bool) {
        let switchHeightPredicate = "\(switchView.intrinsicContentSize().height)"
        
        switchView.constrainHeight(switchHeightPredicate)
        switchView.alignTop("\(64+VerticalMargins)", leading: "\(HorizontalMargins)", bottom: nil, trailing: "-\(HorizontalMargins)", toView: view)
        collectionView.constrainTopSpaceToView(switchView, predicate: "0")
        collectionView.alignTop(nil, leading: "0", bottom: "0", trailing: "0", toView: view)
        collectionView.contentInset = UIEdgeInsetsMake(40, 0, 80, 0)
    }
}

extension ListingsViewController {
    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> ListingsViewController {
        return storyboard.viewControllerWithID(.AuctionListings) as! ListingsViewController
    }
}

// MARK: - Collection View

extension ListingsViewController: UICollectionViewDataSource, UICollectionViewDelegate, ARCollectionViewMasonryLayoutDelegate {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfSaleArtworks
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath)

        if let listingsCell = cell as? ListingsCollectionViewCell {

            listingsCell.downloadImage = downloadImage
            listingsCell.cancelDownloadImage = cancelDownloadImage

            listingsCell.viewModel = viewModel.saleArtworkViewModelAtIndexPath(indexPath)

            let bidSignal: RACSignal = listingsCell.bidWasPressedSignal.takeUntil(cell.rac_prepareForReuseSignal)
            bidSignal.subscribeNext({ [weak self] (_) -> Void in
                self?.viewModel.presentModalForSaleArtworkAtIndexPath(indexPath)
            })
            
            let moreInfoSignal = listingsCell.moreInfoSignal.takeUntil(cell.rac_prepareForReuseSignal)
            moreInfoSignal.subscribeNext({ [weak self] (_) -> Void in
                self?.viewModel.showDetailsForSaleArtworkAtIndexPath(indexPath)
            })
        }
        
        return cell
    }

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: ARCollectionViewMasonryLayout!, variableDimensionForItemAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return MasonryCollectionViewCell.heightForCellWithImageAspectRatio(viewModel.imageAspectRatioForSaleArtworkAtIndexPath(indexPath))
    }
}

// MARK: Private Methods

private extension ListingsViewController {

    func showDetailsForSaleArtwork(saleArtwork: SaleArtwork) {
        performSegueWithIdentifier(SegueIdentifier.ShowSaleArtworkDetails.rawValue, sender: saleArtwork)
    }

    func presentModalForSaleArtwork(saleArtwork: SaleArtwork) {

        ARAnalytics.event("Bid Button Tapped")

        let storyboard = UIStoryboard.fulfillment()
        let containerController = storyboard.instantiateInitialViewController() as! FulfillmentContainerViewController
        containerController.allowAnimations = allowAnimations

        if let internalNav: FulfillmentNavigationController = containerController.internalNavigationController() {
            internalNav.auctionID = viewModel.auctionID
            internalNav.bidDetails.saleArtwork = saleArtwork
        }

        appDelegate().appViewController.presentViewController(containerController, animated: false, completion: { () -> Void in
            containerController.viewDidAppearAnimation(containerController.allowAnimations)
        })
    }
    
    // MARK: Class methods
    
    class func masonryLayout() -> ARCollectionViewMasonryLayout {
        let layout = ARCollectionViewMasonryLayout(direction: .Vertical)
        layout.itemMargins = CGSizeMake(65, 20)
        layout.dimensionLength = CGFloat(MasonryCollectionViewCellWidth)
        layout.rank = 3
        layout.contentInset = UIEdgeInsetsMake(0.0, 0.0, CGFloat(VerticalMargins), 0.0)
        
        return layout
    }
    
    class func tableLayout(width: CGFloat) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        TableCollectionViewCell.Width = width
        layout.itemSize = CGSizeMake(width, TableCollectionViewCell.Height)
        layout.minimumLineSpacing = 0.0
        
        return layout
    }
}

// MARK: Collection view setup

extension UICollectionView {

    class func listingsCollectionViewWithDelegateDatasource<T where T: UICollectionViewDelegate, T: UICollectionViewDataSource>(delegateDatasource: T) -> UICollectionView {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: ListingsViewController.masonryLayout())
        collectionView.backgroundColor = .clearColor()
        collectionView.dataSource = delegateDatasource
        collectionView.delegate = delegateDatasource
        collectionView.alwaysBounceVertical = true
        collectionView.registerClass(MasonryCollectionViewCell.self, forCellWithReuseIdentifier: MasonryCellIdentifier)
        collectionView.registerClass(TableCollectionViewCell.self, forCellWithReuseIdentifier: TableCellIdentifier)
        collectionView.allowsSelection = false
        return collectionView
    }
}
