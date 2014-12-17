import UIKit
import Swift_RAC_Macros

public class ConfirmYourBidEnterYourEmailViewController: UIViewController {

    @IBOutlet public var emailTextField: UITextField!
    @IBOutlet public var confirmButton: UIButton!
    @IBOutlet public var bidDetailsPreviewView: BidDetailsPreviewView!
    public class func instantiateFromStoryboard() -> ConfirmYourBidEnterYourEmailViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBidEnterEmail) as ConfirmYourBidEnterYourEmailViewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let nav = self.fulfillmentNav()

        bidDetailsPreviewView.bidDetails = nav.bidDetails
        
        let newUserCredentials = nav.bidDetails.newUser
        let emailTextSignal = emailTextField.rac_textSignal()
        RAC(newUserCredentials, "email") <~ emailTextField.rac_textSignal().takeUntil(rac_signalForSelector("viewDidDisappear:"))
        let inputIsEmail = emailTextSignal.map(stringIsEmailAddress)

        confirmButton.rac_command = RACCommand(enabled: inputIsEmail) { [weak self] _ in
            if (self == nil) {
                return RACSignal.empty()
            }

            let endpoint: ArtsyAPI = ArtsyAPI.FindExistingEmailRegistration(email: self!.emailTextField.text)
            return XAppRequest(endpoint, provider:Provider.sharedProvider, method: .HEAD, parameters:endpoint.defaultParameters).filterStatusCode(200).doNext({ (__) -> Void in

                self?.performSegue(.ExistingArtsyUserFound)
                return
            }).doError { (error) -> Void in

                self?.performSegue(.EmailNotFoundonArtsy)
                return
            }
        }

        emailTextField.returnKeySignal().subscribeNext { [weak self] (_) -> Void in
            self?.confirmButton.rac_command.execute(nil)
            return
        }

    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        self.emailTextField.becomeFirstResponder()
    }
}

private extension ConfirmYourBidEnterYourEmailViewController {

    @IBAction func dev_emailFound(sender: AnyObject) {
        performSegue(.ExistingArtsyUserFound)
    }

    @IBAction func dev_emailNotFound(sender: AnyObject) {
        performSegue(.EmailNotFoundonArtsy)
    }

}