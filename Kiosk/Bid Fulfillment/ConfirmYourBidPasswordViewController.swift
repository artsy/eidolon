import UIKit

// Unused ATM

class ConfirmYourBidPasswordViewController: UIViewController {

    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> ConfirmYourBidPasswordViewController {
        return storyboard.viewControllerWithID(.ConfirmYourBid) as! ConfirmYourBidPasswordViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bidDetailsPreviewView.bidDetails = fulfillmentNav().bidDetails
    }
    
    @IBAction func dev_noPhoneNumberFoundTapped(sender: AnyObject) {

    }

}
