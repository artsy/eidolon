import UIKit
import Moya
import ReactiveCocoa
import Swift_RAC_Macros

public class ConfirmYourBidArtsyLoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: TextField!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    @IBOutlet var useArtsyBidderButton: UIButton!
    @IBOutlet var confirmCredentialsButton: Button!

    var createNewAccount = false
    lazy var provider:ReactiveMoyaProvider<ArtsyAPI> = Provider.sharedProvider

    class public func instantiateFromStoryboard(storyboard: UIStoryboard) -> ConfirmYourBidArtsyLoginViewController {
        return storyboard.viewControllerWithID(.ConfirmYourBidArtsyLogin) as! ConfirmYourBidArtsyLoginViewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let titleString = useArtsyBidderButton.titleForState(useArtsyBidderButton.state)! ?? ""
        var attributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            NSFontAttributeName: useArtsyBidderButton.titleLabel!.font];
        let attrTitle = NSAttributedString(string: titleString, attributes:attributes)
        useArtsyBidderButton.setAttributedTitle(attrTitle, forState:useArtsyBidderButton.state)

        let nav = self.fulfillmentNav()
        bidDetailsPreviewView.bidDetails = nav.bidDetails

        emailTextField.text = nav.bidDetails.newUser.email ?? ""

        let emailTextSignal = emailTextField.rac_textSignal()
        let passwordTextSignal = passwordTextField.rac_textSignal()
        RAC(nav.bidDetails.newUser, "email") <~ emailTextSignal.takeUntil(viewWillDisappearSignal())
        RAC(nav.bidDetails.newUser, "password") <~ passwordTextSignal.takeUntil(viewWillDisappearSignal())

        let inputIsEmail = emailTextSignal.map(stringIsEmailAddress)
        let passwordIsLongEnough = passwordTextSignal.map(isZeroLengthString).not()
        let formIsValid = RACSignal.combineLatest([inputIsEmail, passwordIsLongEnough]).and()

        confirmCredentialsButton.rac_command = RACCommand(enabled: formIsValid) { [weak self] _ in
            if (self == nil) {
                return RACSignal.empty()
            }
            return self!.xAuthSignal().try { (accessTokenDict, errorPointer) -> Bool in
                if let accessToken = accessTokenDict["access_token"] as? String {
                    self?.fulfillmentNav().xAccessToken = accessToken
                    return true
                } else {
                    errorPointer.memory = NSError(domain: "eidolon", code: 123, userInfo: [NSLocalizedDescriptionKey : "Error fetching access_token"])
                    return false
                }

            }.then {
                return self?.fulfillmentNav().updateUserCredentials() ?? RACSignal.empty()

            }.then {
                return self?.creditCardSignal().doNext { (cards) -> Void in
                    if (self == nil) { return }

                    if count(cards as! [Card]) > 0 {
                        self!.performSegue(.EmailLoginConfirmedHighestBidder)
                    } else {
                        self!.performSegue(.ArtsyUserHasNotRegisteredCard)
                    }
                } ?? RACSignal.empty()

            }.doError { [weak self] (error) -> Void in
                logger.log("Error logging in: \(error.localizedDescription)")
                logger.log("Error Logging in, likely bad auth creds, email = \(self?.emailTextField.text)")
                self?.showAuthenticationError()
            }
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if count(emailTextField.text) == 0 {
            emailTextField.becomeFirstResponder()
        } else {
            passwordTextField.becomeFirstResponder()
        }
    }

    func showAuthenticationError() {
        confirmCredentialsButton.flashError("Wrong login info")
        passwordTextField.flashForError()
        fulfillmentNav().bidDetails.newUser.password = ""
        passwordTextField.text = ""
    }

    func xAuthSignal() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: emailTextField.text, password: passwordTextField.text)
        return provider.request(endpoint).filterSuccessfulStatusCodes().mapJSON()
    }
    
    @IBAction func forgotPasswordTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: "Forgot Password", message: "Please enter your email address and we'll send you a reset link.", preferredStyle: .Alert)

        let submitAction = UIAlertAction(title: "Send", style: .Default) { [weak alertController] (_) in
            let emailTextField = alertController!.textFields![0] as! UITextField
            self.sendForgotPasswordRequest(emailTextField.text)
            return
        }

        submitAction.enabled = false
        submitAction.enabled = stringIsEmailAddress(emailTextField.text).boolValue

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }

        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "email@domain.com"
            textField.text = self.emailTextField.text

            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                submitAction.enabled = stringIsEmailAddress(textField.text).boolValue
            }
        }

        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)

        self.presentViewController(alertController, animated: true) {}
    }

    func sendForgotPasswordRequest(email: String) {
        let endpoint: ArtsyAPI = ArtsyAPI.LostPasswordNotification(email: email)
        XAppRequest(endpoint).filterSuccessfulStatusCodes().subscribeNext { [weak self] (json) -> Void in
            logger.log("Sent forgot password request")
        }
    }

    func creditCardSignal() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.MyCreditCards
        let authProvider = self.fulfillmentNav().loggedInProvider!
        return authProvider.request(endpoint).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Card.self)
    }

    @IBAction func useBidderTapped(sender: AnyObject) {
        for controller in navigationController!.viewControllers {
            if controller.isKindOfClass(ConfirmYourBidViewController.self) {
                navigationController!.popToViewController(controller as! UIViewController, animated:true);
                break;
            }
        }
    }
}

private extension  ConfirmYourBidArtsyLoginViewController {

    @IBAction func dev_hasCardTapped(sender: AnyObject) {
        self.performSegue(.EmailLoginConfirmedHighestBidder)
    }

    @IBAction func dev_noCardFoundTapped(sender: AnyObject) {
        self.performSegue(.ArtsyUserHasNotRegisteredCard)
    }

}
