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

        for button in [keypad.rightButton, keypad.leftButton] {
            RAC(button, "enabled") <~ pinIsZeroSignal.notEach()
        }

        keypadSignal.subscribeNext(addDigitToPIN)
        deleteSignal.subscribeNext(deleteDigitFromPIN)
        clearSignal.subscribeNext(clearPIN)

        RAC(pinTextField, "text") <~ RACObserve(self, "pin")
        RAC(fulfillmentNav().bidDetails, "bidderPIN") <~ RACObserve(self, "pin")

        bidDetailsPreviewView.bidDetails = fulfillmentNav().bidDetails

        /// verify if we can connect with number & pin
        confirmButton.rac_command = RACCommand(enabled: pinIsZeroSignal.notEach()) { [weak self] _ in
            if (self == nil) {
                return RACSignal.empty()
            }
            let phone = self.fulfilmentNav().bidDetails.newUser.phoneNumber! as String!
            let endpoint: ArtsyAPI = ArtsyAPI.Me
            let testProvider = providerForPIN(pin, number:phone)
            let signal = testProvider.request(endpoint, method:.GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().filterSuccessfulStatusCodes()
            return signal.doNext { _ in
                self?.fulfilmentNav().loggedInProvider = testProvider
                return
            }.then {
                self?.fulfilmentNav().updateUserCredentials() ?? RACSignal.empty()
            }.then {
                self?.checkForCreditCard() ?? RACSignal.empty()
            }.doNext { (cards) in
                if (self == nil) { return }
                if countElements(cards as [Card]) > 0 {
                    self?.performSegue(.EmailLoginConfirmedHighestBidder)

                } else {
                    self?.performSegue(.ArtsyUserHasNotRegisteredCard)
                }
            }
        }
    }

    func providerForPIN(pin:String, number:String) -> ReactiveMoyaProvider<ArtsyAPI> {
        let newEndpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
            var endpoint: Endpoint<ArtsyAPI> = Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)
            return endpoint.endpointByAddingParameters(["auction_pin": pin, "number": number])
        }

        return ReactiveMoyaProvider(endpointsClosure: newEndpointsClosure, stubResponses: APIKeys.sharedKeys.stubResponses)

    }

    func checkForCreditCard() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.MyCreditCards
        let authProvider = self.fulfilmentNav().loggedInProvider!
        return authProvider.request(endpoint, method:.GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Card.self)
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