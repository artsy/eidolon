import UIKit

// Unused ATM

public class ConfirmYourBidPasswordViewController: UIViewController {

    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    class func instantiateFromStoryboard() -> ConfirmYourBidEnterYourEmailViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBid) as ConfirmYourBidEnterYourEmailViewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        bidDetailsPreviewView.bidDetails = fulfillmentNav().bidDetails
    }
    
    @IBAction func dev_noPhoneNumberFoundTapped(sender: AnyObject) {

    }

}
