import UIKit
import Moya
import RxSwift
import Action

class ConfirmYourBidArtsyLoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: TextField!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    @IBOutlet var useArtsyBidderButton: UIButton!
    @IBOutlet var confirmCredentialsButton: Button!

    private let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    var createNewAccount = false
    var provider: NetworkingType!

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> ConfirmYourBidArtsyLoginViewController {
        return storyboard.viewControllerWithID(.ConfirmYourBidArtsyLogin) as! ConfirmYourBidArtsyLoginViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleString = useArtsyBidderButton.titleForState(useArtsyBidderButton.state)! ?? ""
        let attributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            NSFontAttributeName: useArtsyBidderButton.titleLabel!.font];
        let attrTitle = NSAttributedString(string: titleString, attributes:attributes)
        useArtsyBidderButton.setAttributedTitle(attrTitle, forState:useArtsyBidderButton.state)

        let nav = self.fulfillmentNav()
        bidDetailsPreviewView.bidDetails = nav.bidDetails

        emailTextField.text = nav.bidDetails.newUser.email.value ?? ""
        
        let emailText = emailTextField.rx_text.takeUntil(viewWillDisappear)
        let passwordText = passwordTextField.rx_text.takeUntil(viewWillDisappear)

        emailText
            .mapToOptional()
            .bindTo(nav.bidDetails.newUser.email)
            .addDisposableTo(rx_disposeBag)

        passwordText
            .mapToOptional()
            .bindTo(nav.bidDetails.newUser.password)
            .addDisposableTo(rx_disposeBag)

        let inputIsEmail = emailText.map(stringIsEmailAddress)
        let passwordIsLongEnough = passwordText.map(isZeroLengthString).not()
        let formIsValid = [inputIsEmail, passwordIsLongEnough].combineLatestAnd()

        confirmCredentialsButton.rx_action = CocoaAction(enabledIf: formIsValid) { [weak self] _ -> Observable<Void> in
            guard let me = self else { return empty() }

            return me.xAuth()
                .flatMap { accessTokenDict -> Observable<AuthorizedNetworkingType> in
                    guard let accessToken = accessTokenDict["access_token"] as? String else {
                        throw NSError(domain: "eidolon", code: 123, userInfo: [NSLocalizedDescriptionKey : "Error fetching access_token"])
                    }

                    let provider = Networking.newAuthorizedNetworking(accessToken)

                    return just(provider)
                }
                .flatMap { provider -> Observable<AuthorizedNetworkingType> in
                    return me.fulfillmentNav()
                        .updateUserCredentials(provider)
                        .mapReplace(provider)
                }.flatMap { provider -> Observable<Void> in
                    return me.creditCard()
                        .doOnNext { cards in
                            guard let me = self else { return }

                            if cards.count > 0 {
                                me.performSegue(.EmailLoginConfirmedHighestBidder)
                            } else {
                                me.performSegue(.ArtsyUserHasNotRegisteredCard)
                            }
                        }
                        .map(void)

                }.doOnError { [weak self] error in
                    logger.log("Error logging in: \((error as NSError).localizedDescription)")
                    logger.log("Error Logging in, likely bad auth creds, email = \(self?.emailTextField.text)")
                    self?.showAuthenticationError()
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        if segue == .EmailLoginConfirmedHighestBidder {
            let viewController = segue.destinationViewController as! LoadingViewController
            viewController.provider = provider
        } else if segue == .ArtsyUserHasNotRegisteredCard {
            let viewController = segue.destinationViewController as! RegisterViewController
            viewController.provider = provider
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if emailTextField.text.isNilOrEmpty {
            emailTextField.becomeFirstResponder()
        } else {
            passwordTextField.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        _viewWillDisappear.onNext()
    }

    func showAuthenticationError() {
        confirmCredentialsButton.flashError("Wrong login info")
        passwordTextField.flashForError()
        fulfillmentNav().bidDetails.newUser.password.value = ""
        passwordTextField.text = ""
    }

    func xAuth() -> Observable<AnyObject> {
        let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        return provider.request(endpoint).filterSuccessfulStatusCodes().mapJSON()
    }
    
    @IBAction func forgotPasswordTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: "Forgot Password", message: "Please enter your email address and we'll send you a reset link.", preferredStyle: .Alert)

        let submitAction = UIAlertAction.Action("Send", style: .Default)
        let email = Variable("")
        submitAction.rx_action = CocoaAction(enabledIf: email.map(stringIsEmailAddress), workFactory: { () -> Observable<Void> in
            let endpoint: ArtsyAPI = ArtsyAPI.LostPasswordNotification(email: email.value)

            return self.provider.request(endpoint)
                .filterSuccessfulStatusCodes()
                .doOnNext { _ in
                    logger.log("Sent forgot password request")
                }
                .map(void)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }

        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "email@domain.com"
            textField.text = self.emailTextField.text

            textField
                .rx_text
                .bindTo(email)
                .addDisposableTo(textField.rx_disposeBag)

            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                submitAction.enabled = stringIsEmailAddress(textField.text ?? "").boolValue
            }
        }

        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)

        self.presentViewController(alertController, animated: true) {}
    }

    func creditCard() -> Observable<[Card]> {
        let endpoint: ArtsyAPI = ArtsyAPI.MyCreditCards
        return provider
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObjectArray(Card.self)
    }

    @IBAction func useBidderTapped(sender: AnyObject) {
        for controller in navigationController!.viewControllers {
            if controller.isKindOfClass(ConfirmYourBidViewController.self) {
                navigationController!.popToViewController(controller, animated:true);
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
