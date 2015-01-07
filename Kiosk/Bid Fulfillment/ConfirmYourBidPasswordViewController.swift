import UIKit

// Unused ATM

public class ConfirmYourBidPasswordViewController: UIViewController {

    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    class public func instantiateFromStoryboard(storyboard: UIStoryboard) -> ConfirmYourBidPasswordViewController {
        return storyboard.viewControllerWithID(.ConfirmYourBid) as ConfirmYourBidPasswordViewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        bidDetailsPreviewView.bidDetails = fulfillmentNav().bidDetails
    }
    
    @IBAction func dev_noPhoneNumberFoundTapped(sender: AnyObject) {

    }

}
