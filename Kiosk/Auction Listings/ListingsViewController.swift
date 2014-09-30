import UIKit

let HorizontalMargins = 65
let VerticalMargins = 26
let MasonryCellIdentifier = "MasonryCell"
let TableCellIdentifier = "TableCell"

class ListingsViewController: UIViewController {
    var allowAnimations = true
    dynamic var saleArtworks = [SaleArtwork]()
    dynamic var cellIdentifier = MasonryCellIdentifier
    
    lazy var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: ListingsViewController.masonryLayout())!
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.registerClass(MasonryCollectionViewCell.self, forCellWithReuseIdentifier: MasonryCellIdentifier)
        collectionView.registerClass(TableCollectionViewCell.self, forCellWithReuseIdentifier: TableCellIdentifier)
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
        let endpoint: ArtsyAPI = ArtsyAPI.AuctionListings(id: "ici-live-auction")

        RAC(self, "saleArtworks") <~ XAppRequest(endpoint, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(SaleArtwork.self).doNext({ [unowned self] (_) -> Void in
            self.collectionView.reloadData()
        }).catch({ (error) -> RACSignal! in
            println("Error handling thing: \(error.localizedDescription)")
            return RACSignal.empty()
        })
        
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
        
        gridSelectedSignal.map({ (gridSelected) -> AnyObject! in
            switch gridSelected as Bool {
            case true:
                return ListingsViewController.masonryLayout()
            default:
                return ListingsViewController.tableLayout()
            }
        }).subscribeNext { [unowned self] (layout) -> Void in
            // Need to explicitly call animated: fase and reload to avoid animation
            self.collectionView.setCollectionViewLayout(layout as UICollectionViewLayout, animated: false)
            self.collectionView.reloadData()
            
            if countElements(self.saleArtworks) > 0 {
                self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
            }
        }
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
        return countElements(saleArtworks)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        self.presentModalForSaleArtwork(saleArtworkAtIndexPath(indexPath))
    }

    func presentModalForSaleArtwork(saleArtwork:SaleArtwork) {
        let storyboard = UIStoryboard.fulfillment()
        let containerController = storyboard.instantiateInitialViewController() as FulfillmentContainerViewController
        containerController.allowAnimations = allowAnimations

        if let placeBidViewController = containerController.placeBidViewController() {
            placeBidViewController.saleArtwork = saleArtwork
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
        layout.itemMargins = CGSizeMake(65, 65)
        layout.dimensionLength = MasonryCollectionViewCellWidth
        layout.rank = 3
        layout.contentInset = UIEdgeInsetsMake(CGFloat(0), -CGFloat(0), CGFloat(VerticalMargins), CGFloat(0))
        
        return layout
    }
    
    class func tableLayout() -> UICollectionViewFlowLayout {
        return UICollectionViewFlowLayout()
    }
    
    // MARK: Instance methods
    
    func saleArtworkAtIndexPath(indexPath: NSIndexPath) -> SaleArtwork {
        return self.saleArtworks[indexPath.item];
    }
    
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
            return "MostBids"
        case .HighestCurrentBid:
            return "Highest Current Bid"
        case .LowestCurrentBid:
            return "Lowest Current Bid"
        case .Alphabetical:
            return "A—Z"
            }
    }
    
    static func allSwitchValues() -> [SwitchValues] {
        return [Grid, LeastBids, MostBids, HighestCurrentBid, LowestCurrentBid, Alphabetical]
    }
}