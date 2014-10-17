import UIKit

class PlacingBidViewController: UIViewController {

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    let placeBidNetworkModel = PlaceBidNetworkModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        let auctionID = self.fulfillmentNav().auctionID!
        let bidDetails = self.fulfillmentNav().bidDetails

        bidDetailsPreviewView.bidDetails = bidDetails

        placeBidNetworkModel.bidSignal(auctionID, bidDetails:bidDetails).subscribeNext { [weak self] (_) in
            self?.performSegue(.PushtoBidConfirmed)
            return
        }

    }

}
