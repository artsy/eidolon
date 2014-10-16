import UIKit

public class ConfirmYourBidArtsyLoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    var createNewAccount = false

    @IBOutlet var confirmCredentialsButton: UIButton!
    lazy var provider:ReactiveMoyaProvider<ArtsyAPI> = Provider.sharedProvider

    public class func instantiateFromStoryboard() -> ConfirmYourBidArtsyLoginViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBidArtsyLogin) as ConfirmYourBidArtsyLoginViewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let nav = self.fulfillmentNav()
        bidDetailsPreviewView.bidDetails = nav.bidDetails

        let emailTextSignal = emailTextField.rac_textSignal()
        let passwordTextSignal = passwordTextField.rac_textSignal()
        RAC(nav.bidDetails.newUser, "email") <~ emailTextSignal
        RAC(nav.bidDetails.newUser, "password") <~ passwordTextSignal

        let inputIsEmail = emailTextSignal.map(stringIsEmailAddress)
        let passwordIsLongEnough = passwordTextSignal.map(longerThan4CharString)
        let formIsValid = RACSignal.combineLatest([inputIsEmail, passwordIsLongEnough]).reduceAnd()

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

                    if countElements(cards as [Card]) > 0 {
                        self!.performSegue(.EmailLoginConfirmedHighestBidder)
                    } else {
                        self!.performSegue(.ArtsyUserHasNotRegisteredCard)
                    }
                } ?? RACSignal.empty()

            }.doError { (error) -> Void in
                println("Error logging in: \(error.localizedDescription)")
            }
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.becomeFirstResponder()
    }

    func xAuthSignal() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: emailTextField.text, password: passwordTextField.text)
        return provider.request(endpoint, method:.GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON()
    }
    

    @IBAction func createNewAccountTapped(sender: AnyObject) {
        createNewAccount = true
        self.performSegue(.ArtsyUserHasNotRegisteredCard)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .ArtsyUserHasNotRegisteredCard {
            let registrationVC = segue.destinationViewController as RegisterViewController
            registrationVC.createNewUser = createNewAccount
        }
    }

    func creditCardSignal() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.MyCreditCards
        let authProvider = self.fulfillmentNav().loggedInProvider!
        return authProvider.request(endpoint, method:.GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Card.self)
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