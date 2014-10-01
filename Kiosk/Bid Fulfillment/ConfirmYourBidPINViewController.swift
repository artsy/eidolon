import UIKit

class ConfirmYourBidPINViewController: UIViewController {

    var mobileOrBid = ""

    class func instantiateFromStoryboard() -> ConfirmYourBidPINViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBidPIN) as ConfirmYourBidPINViewController
    }

    @IBAction func dev_loggedInTapped(sender: AnyObject) {
        self.performSegue(.PINConfirmed)
    }

}
