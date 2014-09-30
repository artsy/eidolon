import UIKit

let horizontalMargins = 65
let verticalMargins = 26
let CellIdentifier = "Cell"

class ListingsViewController: UIViewController {
    var allowAnimations = true
    var salesArtworks = [SaleArtwork]()
    
    lazy var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())!
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier)
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

        RAC(self, "salesArtworks") <~ XAppRequest(endpoint, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(SaleArtwork.self).doNext { [unowned self] (_) -> Void in
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        let switchHeightPredicate = "\(switchView.intrinsicContentSize().height)"
        
        switchView.constrainHeight(switchHeightPredicate)
        switchView.alignTop("\(64+verticalMargins)", leading: "\(horizontalMargins)", bottom: nil, trailing: "-\(horizontalMargins)", toView: view)
        collectionView.constrainTopSpaceToView(switchView, predicate: "\(verticalMargins)")
        collectionView.alignTop(nil, leading: "\(horizontalMargins)", bottom: "0", trailing: "-\(horizontalMargins)", toView: view)
    }
}

// MARK: - Collection View

extension ListingsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countElements(salesArtworks)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        cell.backgroundColor = UIColor.blackColor()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let storyboard = UIStoryboard.fulfillment()
        let containerController = storyboard.instantiateInitialViewController() as FulfillmentContainerViewController
        
        if let placeBidViewController = containerController.placeBidViewController() {
            placeBidViewController.saleArtwork = salesArtworks[indexPath.row]
        }
        
        self.presentViewController(containerController, animated: self.allowAnimations, completion: nil)
    }
}

// MARK: - Switch Values

enum SwitchValues {
    case Grid
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