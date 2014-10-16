import UIKit

class YourBiddingDetailsViewController: UIViewController {

    @IBOutlet dynamic var bidderNumberLabel: UILabel!
    @IBOutlet dynamic var pinNumberLabel: UILabel!
    dynamic var finishAfterViewController = false

    @IBOutlet weak var confirmButton: ActionButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let nav = self.navigationController as? FulfillmentNavigationController {
            RAC(bidderNumberLabel, "text") <~ RACObserve(nav.bidDetails, "bidderNumber")
        }

        if finishAfterViewController {
            confirmButton.setTitle("BACK TO AUCTION", forState: .Normal )
        }
    }

    @IBAction func revealAppTapped(sender: AnyObject) {

        pinNumberLabel.text = self.fulfillmentNav().bidDetails.bidderPIN
    }

    @IBAction func confirmButtonTapped(sender: AnyObject) {
        if finishAfterViewController {
            self.fulfillmentNav().parentViewController?.dismissViewControllerAnimated(true, completion: nil)

        } else {

            self.performSegue(.StartPlacingBidFromRegistration)
        }
    }
}
