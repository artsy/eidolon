import UIKit

class ConfirmYourBidEnterYourEmailViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!

    class func instantiateFromStoryboard() -> ConfirmYourBidEnterYourEmailViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBidEnterEmail) as ConfirmYourBidEnterYourEmailViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let nav = self.navigationController as? FulfillmentNavigationController {

            let newUserCredentials = nav.bidDetails.newUser
            RAC(newUserCredentials, "email") <~ emailTextField.rac_textSignal()
        }

        let inputIsEmail = emailTextField.rac_textSignal().map(stringIsEmailAddress)
        RAC(confirmButton, "enabled") <~ inputIsEmail.notEach()
    }

    @IBAction func dev_emailAdded(sender: AnyObject) {
        self.performSegue(.SubmittedanEmailforUserDetails)
    }
}

private extension ConfirmYourBidEnterYourEmailViewController {


}