import UIKit

class ConfirmYourBidPINViewController: UIViewController {

    dynamic var pin = ""

    @IBOutlet var keypadContainer: KeypadContainerView!
    @IBOutlet var pinTextField: TextField!
    @IBOutlet var confirmButton: Button!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    lazy var keypadSignal:RACSignal! = self.keypadContainer.keypad?.keypadSignal
    lazy var clearSignal:RACSignal!  = self.keypadContainer.keypad?.rightSignal
    lazy var deleteSignal:RACSignal! = self.keypadContainer.keypad?.leftSignal
    lazy var provider:ReactiveMoyaProvider<ArtsyAPI> = Provider.sharedProvider

    class func instantiateFromStoryboard() -> ConfirmYourBidPINViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBidPIN) as ConfirmYourBidPINViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let keypad = self.keypadContainer!.keypad!
        let pinIsZeroSignal = RACObserve(self, "pin").map { (countElements($0 as String) == 0) }

        for button in [confirmButton, keypad.rightButton, keypad.leftButton] {
            RAC(button, "enabled") <~ pinIsZeroSignal.notEach()
        }

        keypadSignal.subscribeNext(addDigitToPIN)
        deleteSignal.subscribeNext(deleteDigitFromPIN)
        clearSignal.subscribeNext(clearPIN)

        RAC(pinTextField, "text") <~ RACObserve(self, "pin")
        RAC(fulfilmentNav().bidDetails, "bidderPIN") <~ RACObserve(self, "pin")

        bidDetailsPreviewView.bidDetails = fulfilmentNav().bidDetails
    }

    @IBAction func enterTapped(sender: AnyObject) {
        /// verify if we can connect with number & pin

        let phone = self.fulfilmentNav().bidDetails.newUser.phoneNumber! as String!

        let endpoint: ArtsyAPI = ArtsyAPI.TrustToken(number:phone, auctionPIN:pin)
        XAppRequest(endpoint, method: .POST).filterSuccessfulStatusCodes().mapJSON().subscribeNext({ [weak self] (json) -> Void in

            if let nav = self?.fulfilmentNav() {
                if let token = json["trust_token"] as? String {
                    nav.trustToken = token
                    nav.xAccessToken = token

                    nav.updateUserCredentials().subscribeNext({ [weak self](_) -> Void in
                        self?.performSegue(.PINConfirmed)
                        return
                    })
                }
            }
            
        }, error: { [weak self] (error) -> Void in
            println("error, the pin is likely wrong")
            return
        })

    }
}

private extension ConfirmYourBidPINViewController {

    func addDigitToPIN(input:AnyObject!) -> Void {
        self.pin = "\(self.pin)\(input)"
    }

    func deleteDigitFromPIN(input:AnyObject!) -> Void {
        self.pin = dropLast(self.pin)
    }

    func clearPIN(input:AnyObject!) -> Void {
        self.pin = ""
    }

    @IBAction func dev_loggedInTapped(sender: AnyObject) {
        self.performSegue(.PINConfirmed)
    }

}