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

    lazy var viewModel = {
        return ListingsViewModel()
    }()

    dynamic var cellIdentifier = MasonryCellIdentifier

    @IBOutlet var stagingFlag: UIImageView!
    @IBOutlet var loadingSpinner: Spinner!
    
    lazy var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: ListingsViewController.masonryLayout())
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.registerClass(MasonryCollectionViewCell.self, forCellWithReuseIdentifier: MasonryCellIdentifier)
        collectionView.registerClass(TableCollectionViewCell.self, forCellWithReuseIdentifier: TableCellIdentifier)
        collectionView.allowsSelection = false
        return collectionView
    }()

    lazy var switchView: SwitchView = {
        return SwitchView(buttonTitles: ListingsViewModel.SwitchValues.allSwitchValueNames())
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel.detectDevelopment() {
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
        RAC(viewModel, "saleArtworks") <~ viewModel.recurringListingsRequestSignal()

        RAC(self, "loadingSpinner.hidden") <~ RACObserve(viewModel, "saleArtworks").mapArrayLengthExistenceToBool()

        let gridSelectedSignal = switchView.selectedIndexSignal.map { (index) -> AnyObject! in
            switch ListingsViewModel.SwitchValues(rawValue: index as! Int) {
            case .Some(.Grid):
                return true
            default:
                return false
            }
        }
        
        RAC(self, "cellIdentifier") <~ gridSelectedSignal.map({ (gridSelected) -> AnyObject! in
            switch gridSelected as! Bool {
            case true:
                return MasonryCellIdentifier
            default:
                return TableCellIdentifier
            }
        })

        let artworkAndLayoutSignal = RACSignal.combineLatest([RACObserve(viewModel, "saleArtworks").distinctUntilChanged(), switchView.selectedIndexSignal, gridSelectedSignal]).map({ [weak self] in
            let tuple = $0 as! RACTuple
            let saleArtworks = tuple.first as! [SaleArtwork]
            let selectedIndex = tuple.second as! Int

            let gridSelected: AnyObject! = tuple.third

            let layout = { () -> UICollectionViewLayout in
                switch gridSelected as! Bool {
                case true:
                    return ListingsViewController.masonryLayout()
                default:
                    return ListingsViewController.tableLayout(CGRectGetWidth(self?.switchView.frame ?? CGRectZero))
                }
            }()

            if let switchValue = ListingsViewModel.SwitchValues(rawValue: selectedIndex) {
                return RACTuple(objectsFromArray: [switchValue.sortSaleArtworks(saleArtworks), layout])
            } else {
                // Necessary for compiler – won't execute
                return RACTuple(objectsFromArray: [saleArtworks, layout])
            }
        })

        let sortedSaleArtworksSignal = artworkAndLayoutSignal.map { ($0 as! RACTuple).first }

        RAC(viewModel, "sortedSaleArtworks") <~ sortedSaleArtworksSignal.doNext{ [weak self] _ -> Void in
            self?.collectionView.reloadData()
            return
        }

        sortedSaleArtworksSignal.dispatchAsyncMainScheduler().subscribeNext { [weak self] in
            let array = ($0 ?? []) as! [SaleArtwork]

            if array.count > 0 {
                // Need to dispatch, since the changes in the CV's model aren't imediate
                self?.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
            }
        }

        artworkAndLayoutSignal.map { ($0 as! RACTuple).second }.subscribeNext { [weak self] (layout) -> Void in
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
        return viewModel.sortedSaleArtworks.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath)

        if let listingsCell = cell as? ListingsCollectionViewCell {

            listingsCell.downloadImage = downloadImage
            listingsCell.cancelDownloadImage = cancelDownloadImage

            listingsCell.saleArtwork = viewModel.saleArtworkAtIndexPath(indexPath)

            let bidSignal: RACSignal = listingsCell.bidWasPressedSignal.takeUntil(cell.rac_prepareForReuseSignal)
            bidSignal.subscribeNext({ [weak self] (_) -> Void in
                if let saleArtwork = self?.viewModel.saleArtworkAtIndexPath(indexPath) {
                    self?.presentModalForSaleArtwork(saleArtwork)
                }
            })
            
            let moreInfoSignal = listingsCell.moreInfoSignal.takeUntil(cell.rac_prepareForReuseSignal)
            moreInfoSignal.subscribeNext({ [weak self] (_) -> Void in
                if let saleArtwork = self?.viewModel.saleArtworkAtIndexPath(indexPath) {
                    self?.presentDetailsForSaleArtwork(saleArtwork)
                }
            })
        }
        
        return cell
    }
    
    func presentDetailsForSaleArtwork(saleArtwork: SaleArtwork) {
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

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: ARCollectionViewMasonryLayout!, variableDimensionForItemAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return MasonryCollectionViewCell.heightForSaleArtwork(viewModel.saleArtworkAtIndexPath(indexPath))
    }
}

// MARK: Private Methods

private extension ListingsViewController {
    
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
