import UIKit

class YourBiddingDetailsViewController: UIViewController {

    @IBOutlet dynamic var bidderNumberLabel: UILabel!
    @IBOutlet dynamic var pinNumberLabel: UILabel!
    @IBOutlet dynamic var bidDetailsView: BidDetailsPreviewView?

    @IBOutlet weak var titleLabel: ARSerifLabel?
    @IBOutlet weak var confirmationImageView: UIImageView?
    @IBOutlet weak var subtitleLabel: ARSerifLabel?

    var titleColor:UIColor?
    var titleText:String?
    var confirmationImage:UIImage?
    var bodyCopy:String?

    @IBOutlet weak var confirmButton: ActionButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let titleColor = titleColor {
            titleLabel?.text = titleText?
            titleLabel?.textColor = titleColor
            confirmationImageView?.image = confirmationImage?
            subtitleLabel?.text = bodyCopy?
        }

        if let nav = self.navigationController as? FulfillmentNavigationController {
            RAC(bidderNumberLabel, "text") <~ RACObserve(nav.bidDetails, "bidderNumber")
        }

        if let preview = bidDetailsView {
            preview.bidDetails = self.fulfillmentNav().bidDetails
        }
    }

    @IBAction func revealAppTapped(sender: AnyObject) {
        pinNumberLabel.text = self.fulfillmentNav().bidDetails.bidderPIN
        let button = sender as ARFlatButton
        button.hidden = true
    }

    @IBAction func confirmButtonTapped(sender: AnyObject) {
        self.fulfillmentNav().parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
