import UIKit

public class ConfirmYourBidEnterYourEmailViewController: UIViewController {

    public class func instantiateFromStoryboard() -> ConfirmYourBidEnterYourEmailViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBidEnterEmail) as ConfirmYourBidEnterYourEmailViewController
    }

    @IBAction public func dev_noPhoneNumberFoundTapped(sender: AnyObject) {
        self.performSegue(.SubmittedanEmailforUserDetails)
    }

}
