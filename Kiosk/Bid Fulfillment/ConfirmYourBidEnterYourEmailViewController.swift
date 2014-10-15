import UIKit

class ConfirmYourBidEnterYourEmailViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    
    class func instantiateFromStoryboard() -> ConfirmYourBidEnterYourEmailViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBidEnterEmail) as ConfirmYourBidEnterYourEmailViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nav = self.fulfilmentNav()

        bidDetailsPreviewView.bidDetails = nav.bidDetails
        
        let newUserCredentials = nav.bidDetails.newUser
        RAC(newUserCredentials, "email") <~ emailTextField.rac_textSignal()

        let inputIsEmail = emailTextField.rac_textSignal().map(stringIsEmailAddress)

        confirmButton.rac_command = RACCommand(enabled: inputIsEmail) { [weak self] _ in
            if (self == nil) {
                return RACSignal.empty()
            }
            return RACSignal.empty() // TODO: replace with actual API signal
        }
    }

    @IBAction func dev_emailAdded(sender: AnyObject) {
        self.performSegue(.SubmittedanEmailforUserDetails)
    }
}

private extension ConfirmYourBidEnterYourEmailViewController {


}