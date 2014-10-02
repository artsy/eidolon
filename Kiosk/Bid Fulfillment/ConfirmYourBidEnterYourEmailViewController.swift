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

        let inputIsEmail = emailTextField.rac_textSignal().map(isEmailAddress)
        RAC(confirmButton, "enabled") <~ inputIsEmail.notEach()
    }

    @IBAction func dev_emailAdded(sender: AnyObject) {
        self.performSegue(.SubmittedanEmailforUserDetails)
    }
}

private extension ConfirmYourBidEnterYourEmailViewController {

    func isEmailAddress(text:AnyObject!) -> AnyObject! {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let testPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)

        return testPredicate?.evaluateWithObject(text) == false
    }

}