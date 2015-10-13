import UIKit
import Moya
import ReactiveCocoa
import Swift_RAC_Macros

class ConfirmYourBidPINViewController: UIViewController {

    dynamic var pin = ""

    @IBOutlet var keypadContainer: KeypadContainerView!
    @IBOutlet var pinTextField: TextField!
    @IBOutlet var confirmButton: Button!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    lazy var pinSignal: RACSignal = { self.keypadContainer.stringValueSignal }()
    
    lazy var provider: ReactiveCocoaMoyaProvider<ArtsyAPI> = Provider.sharedProvider

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> ConfirmYourBidPINViewController {
        return storyboard.viewControllerWithID(.ConfirmYourBidPIN) as! ConfirmYourBidPINViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        RAC(self, "pin") <~ pinSignal
        RAC(pinTextField, "text") <~ pinSignal
        RAC(fulfillmentNav().bidDetails, "bidderPIN") <~ pinSignal
        
        let pinExistsSignal = pinSignal.map { ($0 as! String).isNotEmpty }

        bidDetailsPreviewView.bidDetails = fulfillmentNav().bidDetails

        /// verify if we can connect with number & pin

        confirmButton.rac_command = RACCommand(enabled: pinExistsSignal) { [weak self] _ in
            guard let strongSelf = self else { return RACSignal.empty() }

            let phone = strongSelf.fulfillmentNav().bidDetails.newUser.phoneNumber ?? ""
            let endpoint: ArtsyAPI = ArtsyAPI.Me

            let loggedInProvider = strongSelf.providerForPIN(strongSelf.pin, number: phone)

            return loggedInProvider.request(endpoint).filterSuccessfulStatusCodes().doNext { _ in
                // If the request to ArtsyAPI.Me succeeds, we have logged in and can use this provider.
                self?.fulfillmentNav().loggedInProvider = loggedInProvider
            }.then {
                // We want to put the data we've collected up to the server.
                self?.fulfillmentNav().updateUserCredentials() ?? RACSignal.empty()
            }.then {
                // This looks for credit cards on the users account, and sends them on the signal
                self?.checkForCreditCard() ?? RACSignal.empty()
            }.doNext { (cards) in
                // If the cards list doesn't exist, or its empty, then perform the segue to collect one.
                // Otherwise, proceed directly to the loading view controller to place the bid.
                if (cards as? [Card]).isNilOrEmpty {
                    self?.performSegue(.ArtsyUserviaPINHasNotRegisteredCard)
                } else {
                    self?.performSegue(.PINConfirmedhasCard)
                }

            }.doError({ [weak self] (error) -> Void in
                if let response = error.userInfo["data"] as? MoyaResponse {
                    let responseBody = NSString(data: response.data, encoding: NSUTF8StringEncoding)
                    print("Error authenticating(\(response.statusCode)): \(responseBody)")
                }
                self?.showAuthenticationError()
                return
            })
        }
    }

    @IBAction func forgotPINTapped(sender: AnyObject) {
        let auctionID = fulfillmentNav().auctionID
        let number = fulfillmentNav().bidDetails.newUser.phoneNumber ?? ""
        let endpoint: ArtsyAPI = ArtsyAPI.BidderDetailsNotification(auctionID: auctionID, identifier: number)

        let alertController = UIAlertController(title: "Forgot PIN", message: "We have sent your bidder details to your device.", preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "Back", style: .Cancel) { (_) in }
        alertController.addAction(cancelAction)

        self.presentViewController(alertController, animated: true) {}

        XAppRequest(endpoint, provider: Provider.sharedProvider).filterSuccessfulStatusCodes().subscribeNext { (_) -> Void in
            // Necessary to subscribe to the actual signal. This should be in a RACCommand of the button, instead. 
            logger.log("Sent forgot PIN request")
        }
    }

    func providerForPIN(pin: String, number: String) -> ReactiveCocoaMoyaProvider<ArtsyAPI> {
        let newEndpointsClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
            let endpoint: Endpoint<ArtsyAPI> = Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, {target.sampleData}), method: target.method, parameters: target.parameters)

            let auctionID = self.fulfillmentNav().auctionID
            return endpoint.endpointByAddingParameters(["auction_pin": pin, "number": number, "sale_id": auctionID])
        }

        return ReactiveCocoaMoyaProvider(endpointClosure: newEndpointsClosure, endpointResolver: endpointResolver(), stubBehavior: Provider.APIKeysBasedStubBehaviour)

    }

    func showAuthenticationError() {
        confirmButton.flashError("Wrong PIN")
        pinTextField.flashForError()
        keypadContainer.resetCommand.execute(nil)
    }

    func checkForCreditCard() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.MyCreditCards
        let authProvider = self.fulfillmentNav().loggedInProvider!
        return authProvider.request(endpoint).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Card.self)
    }
}

private extension ConfirmYourBidPINViewController {
    @IBAction func dev_loggedInTapped(sender: AnyObject) {
        self.performSegue(.PINConfirmedhasCard)
    }
}