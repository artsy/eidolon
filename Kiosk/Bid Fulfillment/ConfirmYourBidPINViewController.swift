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

    public lazy var keypadSignal: RACSignal! = self.keypadContainer.keypad?.keypadSignal
    public lazy var clearSignal: RACSignal!  = self.keypadContainer.keypad?.rightSignal
    public lazy var deleteSignal: RACSignal! = self.keypadContainer.keypad?.leftSignal
    public lazy var provider: ReactiveMoyaProvider<ArtsyAPI> = Provider.sharedProvider

    class public func instantiateFromStoryboard(storyboard: UIStoryboard) -> ConfirmYourBidPINViewController {
        return storyboard.viewControllerWithID(.ConfirmYourBidPIN) as ConfirmYourBidPINViewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let keypad = self.keypadContainer!.keypad!
        let pinIsZeroSignal = RACObserve(self, "pin").map { (countElements($0 as String) != 4) }

        for button in [keypad.rightButton, keypad.leftButton] {
            RAC(button, "enabled") <~ pinIsZeroSignal.not()
        }

        keypadSignal.subscribeNext(addDigitToPIN)
        deleteSignal.subscribeNext(deleteDigitFromPIN)
        clearSignal.subscribeNext(clearPIN)

        RAC(pinTextField, "text") <~ RACObserve(self, "pin")
        RAC(fulfillmentNav().bidDetails, "bidderPIN") <~ RACObserve(self, "pin")

        bidDetailsPreviewView.bidDetails = fulfillmentNav().bidDetails

        /// verify if we can connect with number & pin

        confirmButton.rac_command = RACCommand(enabled: pinIsZeroSignal.not()) { [weak self] _ in
            if (self == nil) { return RACSignal.empty() }

            let phone = self!.fulfillmentNav().bidDetails.newUser.phoneNumber
            let endpoint: ArtsyAPI = ArtsyAPI.Me

            let testProvider = self!.providerForPIN(self!.pin, number:phone!)

            return testProvider.request(endpoint, method:.GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().doNext { _ in

                self?.fulfillmentNav().loggedInProvider = testProvider
                return

            }.then {
                self?.fulfillmentNav().updateUserCredentials() ?? RACSignal.empty()

            }.then {
                self?.checkForCreditCard() ?? RACSignal.empty()

            }.doNext { (cards) in
                if (self == nil) { return }
                if countElements(cards as [Card]) > 0 {
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

        XAppRequest(endpoint, provider: Provider.sharedProvider, method: .PUT, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().subscribeNext { (_) -> Void in
            println("sent")
        }
    }

    public func providerForPIN(pin:String, number:String) -> ReactiveMoyaProvider<ArtsyAPI> {
        let newEndpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
            var endpoint: Endpoint<ArtsyAPI> = Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)

            let auctionID = self.fulfillmentNav().auctionID
            return endpoint.endpointByAddingParameters(["auction_pin": pin, "number": number, "sale_id": auctionID])
        }

        return ReactiveMoyaProvider(endpointsClosure: newEndpointsClosure, endpointResolver: endpointResolver(), stubResponses: APIKeys.sharedKeys.stubResponses)

    }

    func showAuthenticationError() {
        confirmButton.flashError("Wrong PIN")
        pinTextField.flashForError()
        pinTextField.text = ""
        pin = ""
    }

    func checkForCreditCard() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.MyCreditCards
        let authProvider = self.fulfillmentNav().loggedInProvider!
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
        self.performSegue(.PINConfirmedhasCard)
    }
}