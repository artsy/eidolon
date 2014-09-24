import UIKit

public class ConfirmYourBidViewController: UIViewController {

    public class func instantiateFromStoryboard() -> ConfirmYourBidViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBid) as ConfirmYourBidViewController
    }

    @IBAction public func dev_noPhoneNumberFoundTapped(sender: AnyObject) {
        self.performSegue(.ConfirmyourBidBidderFound)
    }

    @IBAction public func dev_phoneNumberFoundTapped(sender: AnyObject) {

    }

}
