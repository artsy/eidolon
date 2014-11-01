import UIKit

let HorizontalMargins = 65
let VerticalMargins = 26
let MasonryCellIdentifier = "MasonryCell"
let TableCellIdentifier = "TableCell"

class ListingsViewController: UIViewController {
    var allowAnimations = true
    var auctionID = AppSetup.sharedState.auctionID
    var syncInterval = SyncInterval
    var pageSize = 10
    var schedule = { (signal: RACSignal, scheduler: RACScheduler) -> RACSignal in
        return signal.deliverOn(scheduler)
    }
    
    dynamic var sale = Sale(id: "", name: "", isAuction: true, startDate: NSDate(), endDate: NSDate(), artworkCount: 0, state: "")
    dynamic var saleArtworks = [SaleArtwork]()
    dynamic var sortedSaleArtworks = [SaleArtwork]()
    dynamic var cellIdentifier = MasonryCellIdentifier

    @IBOutlet var stagingFlag: UIImageView!
    @IBOutlet var loadingSpinner: Spinner!
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
    
    class func instantiateFromStoryboard() -> ListingsViewController {
        return UIStoryboard.auction().viewControllerWithID(.AuctionListings) as ListingsViewController
    }
    
    // Recursively calls itself with page+1 until the count of the returned array is < pageSize
    // Sends new response objects to the subject.
    func recursiveListingsRequestSignal(auctionID: String, page: Int, subject: RACSubject) -> RACSignal {
        let artworksEndpoint: ArtsyAPI = ArtsyAPI.AuctionListings(id: auctionID)
        
        return XAppRequest(artworksEndpoint, parameters: ["size": self.pageSize, "page": page]).filterSuccessfulStatusCodes().mapJSON().flattenMap({ (object) -> RACStream! in
            if let array = object as? Array<AnyObject> {
                let count = countElements(array)
                
                subject.sendNext(object)
                if count < self.pageSize {
                    subject.sendCompleted()
                    return nil
                } else {
                    return self.recursiveListingsRequestSignal(auctionID, page: page+1, subject: subject)
                }
            }
            
            // Should never happen
            subject.sendCompleted()
            return nil
        })
    }
    
    // Fetches all pages of the auction
    func allListingsRequestSignal(auctionID: String) -> RACSignal {
        let initialSubject = RACReplaySubject()
        
        return schedule(schedule(recursiveListingsRequestSignal(auctionID, page: 1, subject: initialSubject).ignoreValues(), RACScheduler(priority: RACSchedulerPriorityDefault)).then { initialSubject }.collect().map({ (object) -> AnyObject! in
            // object is an array of arrays (thanks to collect()). We need to flatten it.
            
            let array = object as? Array<Array<AnyObject>>
            return reduce(array ?? [], Array<AnyObject>(), +)
        }).mapToObjectArray(SaleArtwork.self).catch({ (error) -> RACSignal! in
            
            log.error("Sale Artworks: Error handling thing: \(error.artsyServerError())")

            return RACSignal.empty()
        }), RACScheduler.mainThreadScheduler())
    }
    
    func recurringListingsRequestSigal(auctionID: String) -> RACSignal {
        let recurringSignal = RACSignal.interval(syncInterval, onScheduler: RACScheduler.mainThreadScheduler()).startWith(NSDate()).takeUntil(rac_willDeallocSignal())
        
        return recurringSignal.filter({ [weak self] (_) -> Bool in
            self?.shouldSync() ?? false
        }).doNext({ (date) -> Void in
            println("Syncing on \(date)")
        }).map ({ [weak self] (_) -> AnyObject! in
            return self?.allListingsRequestSignal(auctionID) ?? RACSignal.empty()
        }).switchToLatest().map({ [weak self] (newSaleArtworks) -> AnyObject! in
            if self == nil {
                return [] // Now safe to use self!
            }
            let currentSaleArtworks = self!.saleArtworks
            
            func update(currentSaleArtworks: [SaleArtwork], newSaleArtworks: [SaleArtwork]) -> Bool {
                assert(countElements(currentSaleArtworks) == countElements(newSaleArtworks), "Arrays' counts must be equal.")
                // Updating the currentSaleArtworks is easy. First we sort both according to the same criteria
                // Because we assume that their length is the same, we just do a linear scane through and
                // copy values from the new to the old.
                
                let sortedCurentSaleArtworks = currentSaleArtworks.sorted(sortById)
                let sortedNewSaleArtworks = newSaleArtworks.sorted(sortById)
                
                let count = countElements(sortedCurentSaleArtworks)
                for var i = 0; i < count; i++ {
                    if currentSaleArtworks[i].id == newSaleArtworks[i].id {
                        currentSaleArtworks[i].updateWithValues(newSaleArtworks[i])
                    } else {
                        // Failure: the list was the same size but had different artworks
                        return false
                    }
                }

                return true
            }
            
            // So we want to do here is pretty simple – if the existing and new arrays are of the same length,
            // then update the individual values in the current array and return the existing value.
            // If the array's length has changed, then we pass through the new array
            if let newSaleArtworks = newSaleArtworks as? Array<SaleArtwork> {
                if countElements(newSaleArtworks) == countElements(currentSaleArtworks) {
                    if update(currentSaleArtworks, newSaleArtworks) {
                        return currentSaleArtworks
                    }
                }
            }
            
            return newSaleArtworks
        })
    }
    
    func shouldSync() -> Bool {
        return self.presentedViewController == nil && self.navigationController?.topViewController == self
    }
    
    func auctionRequestSignal(auctionID: String) -> RACSignal {
        let auctionEndpoint: ArtsyAPI = ArtsyAPI.AuctionInfo(auctionID: auctionID)
        
        return XAppRequest(auctionEndpoint).filterSuccessfulStatusCodes().mapJSON().mapToObject(Sale.self).catch({ (error) -> RACSignal! in
            
            log.error("Sale Artworks: Error handling thing: \(error.artsyServerError())")
            return RACSignal.empty()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        #if (arch(i386) || arch(x86_64)) && os(iOS)
            let flagImageName = AppSetup.sharedState.useStaging ? "StagingFlag" : "ProductionFlag"
            stagingFlag.image = UIImage(named: flagImageName)
        #else
            stagingFlag.hidden = AppSetup.sharedState.useStaging == false
        #endif

        // Add subviews
        view.addSubview(switchView)
        view.insertSubview(collectionView, belowSubview: loadingSpinner)
        
        // Set up reactive bindings
        RAC(self, "saleArtworks") <~ recurringListingsRequestSigal(auctionID)
        
        RAC(self, "sale") <~ auctionRequestSignal(auctionID)
        RAC(self, "countdownManager.sale") <~ RACObserve(self, "sale")
        RAC(self, "loadingSpinner.hidden") <~ RACObserve(self, "saleArtworks").mapArrayLengthExistenceToBool()

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

        RAC(self, "sortedSaleArtworks") <~ RACSignal.combineLatest([RACObserve(self, "saleArtworks").distinctUntilChanged(), switchView.selectedIndexSignal, gridSelectedSignal]).doNext({ [weak self] in
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
            
            // Need to explicitly call animated: false and reload to avoid animation
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
        }).distinctUntilChanged().doNext({ [weak self] (sortedSaleArtworks) -> Void in
            self?.collectionView.reloadData()
            
            if countElements(sortedSaleArtworks as [SaleArtwork]) > 0 {
                // Need to dispatch, since the changes in the CV's model aren't imediate
                dispatch_async(dispatch_get_main_queue()) {
                    self?.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
                    return
                }
            }
        })
    }

    @IBOutlet weak var registerToBidButton: ActionButton!
    @IBAction func registerTapped(sender: AnyObject) {

        ARAnalytics.event("Register To Bid Tapped")

        let storyboard = UIStoryboard.fulfillment()
        let containerController = storyboard.instantiateInitialViewController() as FulfillmentContainerViewController
        containerController.allowAnimations = allowAnimations

        if let internalNav:FulfillmentNavigationController = containerController.internalNavigationController() {
            let registerVC = storyboard.viewControllerWithID(.RegisterAnAccount) as RegisterViewController
            internalNav.auctionID = self.auctionID
            registerVC.createNewUser = true
            internalNav.viewControllers = [registerVC]
        }

        self.presentViewController(containerController, animated: false) {
            containerController.viewDidAppearAnimation(containerController.allowAnimations)
        }
    }

    @IBAction func longPressForAdmin(sender: AnyObject) {
        let passwordVC = PasswordAlertViewController.alertView { [weak self] () -> () in
            self?.performSegue(.ShowAdminOptions)
            return
        }
        self.presentViewController(passwordVC, animated: true) {}
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

// MARK: - Collection View

extension ListingsViewController: UICollectionViewDataSource, UICollectionViewDelegate, ARCollectionViewMasonryLayoutDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countElements(sortedSaleArtworks)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        if let listingsCell = cell as? ListingsCollectionViewCell {

            // TODO: Ideally we should disable when auction runs out
            // listingsCell.bidButton.enabled = countdownManager.auctionFinishedSignal

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

        ARAnalytics.event("Bid Button Tapped")

        let storyboard = UIStoryboard.fulfillment()
        let containerController = storyboard.instantiateInitialViewController() as FulfillmentContainerViewController
        containerController.allowAnimations = allowAnimations

        if let internalNav:FulfillmentNavigationController = containerController.internalNavigationController() {
            internalNav.auctionID = self.auctionID
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
    return lhs.artwork.artists!.first!.sortableID.caseInsensitiveCompare(rhs.artwork.artists!.first!.sortableID) == .OrderedAscending
}

func sortById(lhs: SaleArtwork, rhs: SaleArtwork) -> Bool {
    return lhs.id.caseInsensitiveCompare(rhs.id) == .OrderedAscending
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
            return "A–Z"
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
