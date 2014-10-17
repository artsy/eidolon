import UIKit

class PlacingBidViewController: UIViewController {

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    let placeBidNetworkModel = PlaceBidNetworkModel()
    var registerNetworkModel: RegistrationNetworkModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        let auctionID = self.fulfillmentNav().auctionID!
        let bidDetails = self.fulfillmentNav().bidDetails

        bidDetailsPreviewView.bidDetails = bidDetails

        RACSignal.empty().then {
            self.registerNetworkModel == nil ? RACSignal.empty() : self.registerNetworkModel?.registerSignal()

        } .then {
            self.placeBidNetworkModel.bidSignal(auctionID, bidDetails:bidDetails)

        } .subscribeNext { [weak self] (_) in
            self?.performSegue(.PushtoBidConfirmed)
            return
        }

    }

}
