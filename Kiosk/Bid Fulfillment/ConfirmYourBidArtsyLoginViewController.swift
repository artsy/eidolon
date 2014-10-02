import UIKit

public class ConfirmYourBidArtsyLoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    @IBOutlet var confirmCredentialsButton: UIButton!

    public class func instantiateFromStoryboard() -> ConfirmYourBidArtsyLoginViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBidArtsyLogin) as ConfirmYourBidArtsyLoginViewController
    }

    @IBAction public func dev_hasCardTapped(sender: AnyObject) {
        self.performSegue(.EmailLoginConfirmedHighestBidder)
    }

    @IBAction public func dev_noCardFoundTapped(sender: AnyObject) {
        self.performSegue(.ArtsyUserHasNotRegisteredCard)
    }



}
