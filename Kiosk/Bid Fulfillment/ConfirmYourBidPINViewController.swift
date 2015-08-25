import UIKit
import Moya
import ReactiveCocoa
import Swift_RAC_Macros

public class ConfirmYourBidPINViewController: UIViewController {

    dynamic var pin = ""

    @IBOutlet public var keypadContainer: KeypadContainerView!
    @IBOutlet public var pinTextField: TextField!
    @IBOutlet public var confirmButton: Button!
    @IBOutlet public var bidDetailsPreviewView: BidDetailsPreviewView!

    public lazy var pinSignal: RACSignal = { self.keypadContainer.stringValueSignal }()
    
    public lazy var provider: ReactiveCocoaMoyaProvider<ArtsyAPI> = Provider.sharedProvider

    class public func instantiateFromStoryboard(storyboard: UIStoryboard) -> ConfirmYourBidPINViewController {
        return storyboard.viewControllerWithID(.ConfirmYourBidPIN) as! ConfirmYourBidPINViewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        RAC(self, "pin") <~ pinSignal
        RAC(pinTextField, "text") <~ pinSignal
        RAC(fulfillmentNav().bidDetails, "bidderPIN") <~ pinSignal
        
        let pinExistsSignal = pinSignal.map { ($0 as! String).isEmpty == false }

        bidDetailsPreviewView.bidDetails = fulfillmentNav().bidDetails

        /// verify if we can connect with number & pin

        confirmButton.rac_command = RACCommand(enabled: pinExistsSignal) { [weak self] _ in
            if (self == nil) { return RACSignal.empty() }

            let phone = self!.fulfillmentNav().bidDetails.newUser.phoneNumber
            let endpoint: ArtsyAPI = ArtsyAPI.Me

            let testProvider = self!.providerForPIN(String(self!.pin), number:phone!)

            return testProvider.request(endpoint).filterSuccessfulStatusCodes().doNext { _ in

                self?.fulfillmentNav().loggedInProvider = testProvider
                return

            }.then {
                self?.fulfillmentNav().updateUserCredentials() ?? RACSignal.empty()

            }.then {
                self?.checkForCreditCard() ?? RACSignal.empty()

            }.doNext { (cards) in
                if (self == nil) { return }
                if (cards as! [Card]).count > 0 {
                    self?.performSegue(.PINConfirmedhasCard)

                } else {
                    self?.performSegue(.ArtsyUserviaPINHasNotRegisteredCard)
                }

            }.doError({ [weak self] (error) -> Void in
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

    public func providerForPIN(pin: String, number: String) -> ReactiveCocoaMoyaProvider<ArtsyAPI> {
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