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
        bidDetailsPreviewView.bidDetails = fulfilmentNav().bidDetails
    }

    @IBAction func enterTapped(sender: AnyObject) {
        /// verify if we can connect with number & pin

        let phone = self.fulfilmentNav().bidDetails.newUser.phoneNumber! as String!

        let newEndpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
            var endpoint: Endpoint<ArtsyAPI> = Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)
            return endpoint.endpointByAddingParameters(["auction_pin": self.pin, "number": phone])
        }
        
        let numberProvider:ReactiveMoyaProvider<ArtsyAPI> = ReactiveMoyaProvider(endpointsClosure: newEndpointsClosure, stubResponses: APIKeys.sharedKeys.stubResponses)

        let endpoint: ArtsyAPI = ArtsyAPI.Me
        let bidderRequest = XAppRequest(endpoint, provider: numberProvider).filterSuccessfulStatusCodes().subscribeNext({ [weak self] (_) -> Void in

            if let nav = self?.fulfilmentNav() {
                nav.providerEndpointResolver = newEndpointsClosure
                
                nav.updateUserCredentials().subscribeNext({ [weak self](_) -> Void in
                    println("P:1.5")
                    self?.performSegue(.PINConfirmed)
                    return
                })
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