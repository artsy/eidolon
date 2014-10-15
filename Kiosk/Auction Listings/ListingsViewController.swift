import UIKit

let HorizontalMargins = 65
let VerticalMargins = 26
let MasonryCellIdentifier = "MasonryCell"
let TableCellIdentifier = "TableCell"

class ListingsViewController: UIViewController {
    var allowAnimations = true
    var auctionID = AuctionID
    
    dynamic var sale = Sale(id: "", isAuction: true, startDate: NSDate(), endDate: NSDate())
    dynamic var saleArtworks = [SaleArtwork]()
    dynamic var sortedSaleArtworks = [SaleArtwork]()
    dynamic var cellIdentifier = MasonryCellIdentifier
    
    @IBOutlet var countdownManager: ListingsCountdownManager!
    
    lazy var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: ListingsViewController.masonryLayout())!
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
        return SwitchView(buttonTitles: SwitchValues.allSwitchValues().map{$0.name.uppercaseString})
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add subviews
        view.addSubview(switchView)
        view.addSubview(collectionView)
        
        // Set up reactive bindings
        let artworksEndpoint: ArtsyAPI = ArtsyAPI.AuctionListings(id: auctionID)
        
        RAC(self, "saleArtworks") <~ XAppRequest(artworksEndpoint).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(SaleArtwork.self).catch({ (error) -> RACSignal! in
            
            if let genericError = error.artsyServerError() {
                println("Sale Artworks: Error handling thing: \(genericError.message)")
            }
            return RACSignal.empty()
        })
        
        let auctionEndpoint: ArtsyAPI = ArtsyAPI.AuctionInfo(auctionID: auctionID)
        
        RAC(self, "sale") <~ XAppRequest(auctionEndpoint).filterSuccessfulStatusCodes().mapJSON().mapToObject(Sale.self)
        RAC(self, "countdownManager.sale") <~ RACObserve(self, "sale")

        
        let gridSelectedSignal = switchView.selectedIndexSignal.map { (index) -> AnyObject! in
            switch index as Int {
            case SwitchValues.Grid.rawValue:
                return true
            default:
                return false
            }
        }
        
        RAC(self, "cellIdentifier") <~ gridSelectedSignal.map({ (gridSelected) -> AnyObject! in
            switch gridSelected as Bool {
            case true:
                return MasonryCellIdentifier
            default:
                return TableCellIdentifier
            }
        })
        
        RAC(self, "sortedSaleArtworks") <~ RACSignal.combineLatest([RACObserve(self, "saleArtworks"), switchView.selectedIndexSignal, gridSelectedSignal]).doNext({ [weak self] in
            let tuple = $0 as RACTuple
            let gridSelected: AnyObject! = tuple.third
            
            let layout = { () -> UICollectionViewLayout in
                switch gridSelected as Bool {
                case true:
                    return ListingsViewController.masonryLayout()
                default:
                    return ListingsViewController.tableLayout(CGRectGetWidth(self?.switchView.frame ?? CGRectZero))
                }
            }()
            
            // Need to explicitly call animated: fase and reload to avoid animation
            self?.collectionView.setCollectionViewLayout(layout, animated: false)
        }).map({
            let tuple = $0 as RACTuple
            let saleArtworks = tuple.first as [SaleArtwork]
            let selectedIndex = tuple.second as Int
            
            if let switchValue = SwitchValues(rawValue: selectedIndex) {
                return switchValue.sortSaleArtworks(saleArtworks)
            } else {
                // Necessary for compiler – won't execute
                return saleArtworks
            }
        }).doNext({ [weak self] (sortedSaleArtworks) -> Void in
            self?.collectionView.reloadData()
            
            if countElements(sortedSaleArtworks as [SaleArtwork]) > 0 {
                // Need to dispatch, since the changes in the CV's model aren't imediate
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self?.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
                    return
                })
            }
        })
    }

    @IBAction func registerTapped(sender: AnyObject) {

        let storyboard = UIStoryboard.fulfillment()
        let containerController = storyboard.instantiateInitialViewController() as FulfillmentContainerViewController
        containerController.allowAnimations = allowAnimations

        if let internalNav:FulfillmentNavigationController = containerController.internalNavigationController() {
            let registerVC = RegisterViewController.instantiateFromStoryboard()
            registerVC.createNewUser = true
            internalNav.viewControllers = [registerVC]
        }

        self.presentViewController(containerController, animated: false) {
            containerController.viewDidAppearAnimation(containerController.allowAnimations)
        }

    }
    
    @IBAction func longPressForAdmin(sender: AnyObject) {
        self.performSegue(.ShowAdminOptions)
    }
    
    override func viewWillAppear(animated: Bool) {
        let switchHeightPredicate = "\(switchView.intrinsicContentSize().height)"
        
        switchView.constrainHeight(switchHeightPredicate)
        switchView.alignTop("\(64+VerticalMargins)", leading: "\(HorizontalMargins)", bottom: nil, trailing: "-\(HorizontalMargins)", toView: view)
        collectionView.constrainTopSpaceToView(switchView, predicate: "\(VerticalMargins)")
        collectionView.alignTop(nil, leading: "0", bottom: "0", trailing: "0", toView: view)
    }
}

// MARK: - Collection View

extension ListingsViewController: UICollectionViewDataSource, UICollectionViewDelegate, ARCollectionViewMasonryLayoutDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countElements(sortedSaleArtworks)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        if let listingsCell = cell as? ListingsCollectionViewCell {
            listingsCell.saleArtwork = saleArtworkAtIndexPath(indexPath)
            let bidSignal: RACSignal = listingsCell.bidWasPressedSignal.takeUntil(cell.rac_prepareForReuseSignal)
            bidSignal.subscribeNext({ [weak self] (_) -> Void in
                if let saleArtwork = self?.saleArtworkAtIndexPath(indexPath) {
                    self?.presentModalForSaleArtwork(saleArtwork)
                }
            })
        }
        
        return cell
    }

    func presentModalForSaleArtwork(saleArtwork:SaleArtwork) {
        let storyboard = UIStoryboard.fulfillment()
        let containerController = storyboard.instantiateInitialViewController() as FulfillmentContainerViewController
        containerController.allowAnimations = allowAnimations

        if let internalNav:FulfillmentNavigationController = containerController.internalNavigationController() {
            internalNav.bidDetails.saleArtwork = saleArtwork
        }

        // Present the VC, then once it's ready trigger it's own showing animations
        self.presentViewController(containerController, animated: false) {
            containerController.viewDidAppearAnimation(containerController.allowAnimations)
        }
    }

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: ARCollectionViewMasonryLayout!, variableDimensionForItemAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return MasonryCollectionViewCell.heightForSaleArtwork(saleArtworkAtIndexPath(indexPath))
    }
}

// Mark: Private Methods

private extension ListingsViewController {
    
    // MARK: Class methods
    
    class func masonryLayout() -> ARCollectionViewMasonryLayout {
        var layout = ARCollectionViewMasonryLayout(direction: .Vertical)
        layout.itemMargins = CGSizeMake(65, 0)
        layout.dimensionLength = MasonryCollectionViewCellWidth
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
    
    // MARK: Instance methods
    
    func saleArtworkAtIndexPath(indexPath: NSIndexPath) -> SaleArtwork {
        return sortedSaleArtworks[indexPath.item];
    }
    
}

// MARK: - Sorting Functions

func leastBidsSort(lhs: SaleArtwork, rhs: SaleArtwork) -> Bool {
    return (lhs.bidCount ?? 0) < (rhs.bidCount ?? 0)
}

func mostBidsSort(lhs: SaleArtwork, rhs: SaleArtwork) -> Bool {
    return !leastBidsSort(lhs, rhs)
}

func lowestCurrentBidSort(lhs: SaleArtwork, rhs: SaleArtwork) -> Bool {
    return (lhs.highestBidCents ?? 0) < (rhs.highestBidCents ?? 0)
}

func highestCurrentBidSort(lhs: SaleArtwork, rhs: SaleArtwork) -> Bool {
    return !lowestCurrentBidSort(lhs, rhs)
}

func alphabeticalSort(lhs: SaleArtwork, rhs: SaleArtwork) -> Bool {
    return lhs.artwork.title.caseInsensitiveCompare(rhs.artwork.title) == .OrderedAscending
}

// MARK: - Switch Values

enum SwitchValues: Int {
    case Grid = 0
    case LeastBids
    case MostBids
    case HighestCurrentBid
    case LowestCurrentBid
    case Alphabetical
    
    var name: String {
        switch self {
        case .Grid:
            return "Grid"
        case .LeastBids:
            return "Least Bids"
        case .MostBids:
            return "Most Bids"
        case .HighestCurrentBid:
            return "Highest Bid"
        case .LowestCurrentBid:
            return "Lowest Bid"
        case .Alphabetical:
            return "A—Z"
        }
    }
    
    func sortSaleArtworks(saleArtworks: [SaleArtwork]) -> [SaleArtwork] {
        switch self {
        case Grid:
            return saleArtworks
        case LeastBids:
            return saleArtworks.sorted(leastBidsSort)
        case MostBids:
            return saleArtworks.sorted(mostBidsSort)
        case HighestCurrentBid:
            return saleArtworks.sorted(highestCurrentBidSort)
        case LowestCurrentBid:
            return saleArtworks.sorted(lowestCurrentBidSort)
        case Alphabetical:
            return saleArtworks.sorted(alphabeticalSort)
        }
    }
    
    static func allSwitchValues() -> [SwitchValues] {
        return [Grid, LeastBids, MostBids, HighestCurrentBid, LowestCurrentBid, Alphabetical]
    }
}