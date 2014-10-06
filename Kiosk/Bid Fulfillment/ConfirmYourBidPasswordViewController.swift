import UIKit

class ConfirmYourBidPasswordViewController: UIViewController {

    class func instantiateFromStoryboard() -> ConfirmYourBidEnterYourEmailViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBid) as ConfirmYourBidEnterYourEmailViewController
    }

    @IBAction func dev_noPhoneNumberFoundTapped(sender: AnyObject) {
        self.performSegue(.LoggedinWithNewUser)
    }



}
