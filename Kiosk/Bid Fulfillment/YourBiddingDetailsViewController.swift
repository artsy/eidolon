import UIKit

class YourBiddingDetailsViewController: UIViewController {

    @IBOutlet dynamic var bidderNumberLabel: UILabel!
    @IBOutlet dynamic var pinNumberLabel: UILabel!
    @IBOutlet dynamic var bidDetailsView: BidDetailsPreviewView!

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet weak var confirmationImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: ARSerifLabel!
    @IBOutlet weak var bodyLabel: ARSerifLabel!

    var titleColor: UIColor!
    var titleText: String!
    var confirmationImage: UIImage!
    var registered: Bool!
    var hidePreview: Bool!
    var isHighestBidder: Bool!

    @IBOutlet weak var confirmButton: SecondaryActionButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = titleText
        titleLabel.textColor = titleColor
        confirmationImageView.image = confirmationImage
        subtitleLabel.hidden = !registered

        let registeredCopy = "You will be asked for your Bidder Number and PIN next time you bid instead of entering all your information."
        let notRegisteredCopy = "Use your Bidder Number and PIN next time you bid."
        bodyLabel?.text = registered! ? registeredCopy : notRegisteredCopy


        if let nav = self.navigationController as? FulfillmentNavigationController {
            RAC(bidderNumberLabel, "text") <~ RACObserve(nav.bidDetails, "paddleNumber")
        }

        let hidden = hidePreview ?? false
        bidDetailsView?.hidden = hidden
        if !hidden {
            bidDetailsView?.bidDetails = self.fulfillmentNav().bidDetails
        }
    }

    @IBAction func revealAppTapped(sender: AnyObject) {
        pinNumberLabel.text = self.fulfillmentNav().bidDetails.bidderPIN
        let button = sender as ARFlatButton
        button.hidden = true
    }

    @IBAction func confirmButtonTapped(sender: AnyObject) {
        fulfillmentContainer()?.closeFulfillmentModal()
    }
}
