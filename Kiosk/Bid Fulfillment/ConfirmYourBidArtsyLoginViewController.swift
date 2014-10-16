import UIKit

public class ConfirmYourBidArtsyLoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    @IBOutlet var confirmCredentialsButton: UIButton!
    lazy var provider:ReactiveMoyaProvider<ArtsyAPI> = Provider.sharedProvider

    public class func instantiateFromStoryboard() -> ConfirmYourBidArtsyLoginViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBidArtsyLogin) as ConfirmYourBidArtsyLoginViewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let nav = self.fulfilmentNav()
        bidDetailsPreviewView.bidDetails = nav.bidDetails

        RAC(nav.bidDetails.newUser, "email") <~ emailTextField.rac_textSignal()
        RAC(nav.bidDetails.newUser, "password") <~ passwordTextField.rac_textSignal()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.becomeFirstResponder()
    }

    @IBAction func confirmTapped(sender: AnyObject) {

        let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: emailTextField.text, password: passwordTextField.text)

        provider.request(endpoint, method:.GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().subscribeNext({ [weak self] (accessTokenDict) -> Void in

            if let accessToken = accessTokenDict["access_token"] as? String {
                self?.fulfilmentNav().xAccessToken = accessToken

                self?.fulfilmentNav().updateUserCredentials().subscribeNext({ [weak self] (accessTokenDict) -> Void in
                    self?.checkForCreditCard()
                    return
                })
                
            }
        }, error: { (error) -> Void in
                println("Error logging in: \(error.localizedDescription)")
        })
    }

    func checkForCreditCard() {
        let endpoint: ArtsyAPI = ArtsyAPI.MyCreditCards
        let authProvider = self.fulfilmentNav().loggedInProvider!
        authProvider.request(endpoint, method:.GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Card.self).subscribeNext({ [weak self] (cards) -> Void in

            if countElements(cards as [Card]) > 0 {
                self?.performSegue(.EmailLoginConfirmedHighestBidder)

            } else {
                self?.performSegue(.ArtsyUserHasNotRegisteredCard)
            }
            
        }, error: { [weak self] (error) -> Void in
                println("error, the pin is likely wrong")
                return
        })
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