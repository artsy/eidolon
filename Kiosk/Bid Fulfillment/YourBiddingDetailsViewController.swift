import UIKit

class YourBiddingDetailsViewController: UIViewController {

    @IBOutlet dynamic var bidderNumberLabel: UILabel!
    @IBOutlet dynamic var pinNumberLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let nav = self.navigationController as? FulfillmentNavigationController {
            RAC(bidderNumberLabel, "text") <~ RACObserve(nav.bidDetails, "bidderNumber")
        }
    }

    @IBAction func revealAppTapped(sender: AnyObject) {

        pinNumberLabel.text = self.fulfilmentNav().bidDetails.bidderPIN
    }

}
