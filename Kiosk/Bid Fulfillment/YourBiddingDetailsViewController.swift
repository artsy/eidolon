import UIKit

class YourBiddingDetailsViewController: UIViewController {

    @IBOutlet dynamic var bidderNumberLabel: UILabel!
    @IBOutlet dynamic var pinNumberLabel: UILabel!

    @IBOutlet weak var confirmButton: ActionButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let nav = self.navigationController as? FulfillmentNavigationController {
            RAC(bidderNumberLabel, "text") <~ RACObserve(nav.bidDetails, "bidderNumber")
        }
    }

    @IBAction func revealAppTapped(sender: AnyObject) {

        pinNumberLabel.text = self.fulfillmentNav().bidDetails.bidderPIN
    }

    @IBAction func confirmButtonTapped(sender: AnyObject) {
        self.fulfillmentNav().parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
