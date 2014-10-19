import UIKit

class ConfirmYourBidEnterYourEmailViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    var emailSubscription:RACDisposable!

    class func instantiateFromStoryboard() -> ConfirmYourBidEnterYourEmailViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBidEnterEmail) as ConfirmYourBidEnterYourEmailViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nav = self.fulfillmentNav()

        bidDetailsPreviewView.bidDetails = nav.bidDetails
        
        let newUserCredentials = nav.bidDetails.newUser
        let emailTextSignal = emailTextField.rac_textSignal()
        emailSubscription = RAC(newUserCredentials, "email") <~ emailTextSignal

        let inputIsEmail = emailTextSignal.map(stringIsEmailAddress)

        confirmButton.rac_command = RACCommand(enabled: inputIsEmail) { [weak self] _ in
            if (self == nil) {
                return RACSignal.empty()
            }

            let endpoint: ArtsyAPI = ArtsyAPI.FindExistingEmailRegistration(email: self!.emailTextField.text)
            return XAppRequest(endpoint, provider:Provider.sharedProvider, method: .HEAD, parameters:endpoint.defaultParameters).filterStatusCode(200).doNext({ (__) -> Void in
                self?.emailSubscription.dispose()
                self?.performSegue(.ExistingArtsyUserFound)

            }).doError { (error) -> Void in

                self?.performSegue(.EmailNotFoundonArtsy)
                return
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        self.emailTextField.becomeFirstResponder()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .EmailNotFoundonArtsy {
            let registrationVC = segue.destinationViewController as RegisterViewController
            registrationVC.createNewUser = true
            registrationVC.placingBid = true
        }
    }

}

private extension ConfirmYourBidEnterYourEmailViewController {

    @IBAction func dev_emailFound(sender: AnyObject) {
        emailSubscription.dispose()
        performSegue(.ExistingArtsyUserFound)
    }

    @IBAction func dev_emailNotFound(sender: AnyObject) {
        performSegue(.EmailNotFoundonArtsy)
    }

}