import UIKit
import Moya
import RxSwift
import Action

class ConfirmYourBidPINViewController: UIViewController {

    private var _pin = Variable("")

    @IBOutlet var keypadContainer: KeypadContainerView!
    @IBOutlet var pinTextField: TextField!
    @IBOutlet var confirmButton: Button!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    lazy var pin: Observable<String> = { self.keypadContainer.stringValue }()

    var provider: Networking!

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> ConfirmYourBidPINViewController {
        return storyboard.viewControllerWithID(.ConfirmYourBidPIN) as! ConfirmYourBidPINViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pin
            .bindTo(_pin)
            .addDisposableTo(rx_disposeBag)

        pin
            .bindTo(pinTextField.rx_text)
            .addDisposableTo(rx_disposeBag)

        pin
            .mapToOptional()
            .bindTo(fulfillmentNav().bidDetails.bidderPIN)
            .addDisposableTo(rx_disposeBag)
        
        let pinExists = pin.map { $0.isNotEmpty }

        let bidDetails = fulfillmentNav().bidDetails
        let provider = self.provider

        bidDetailsPreviewView.bidDetails = bidDetails
        /// verify if we can connect with number & pin

        confirmButton.rx_action = CocoaAction(enabledIf: pinExists) { [weak self] _ in
            guard let me = self else { return .empty() }

            var loggedInProvider: AuthorizedNetworking!

            return bidDetails.authenticatedNetworking(provider)
                .doOnNext { provider in
                    loggedInProvider = provider
                }
                .flatMap { provider -> Observable<AuthorizedNetworking> in
                    return provider
                        .request(ArtsyAuthenticatedAPI.Me)
                        .filterSuccessfulStatusCodes()
                        .mapReplace(provider)
                }
                .flatMap { provider -> Observable<AuthorizedNetworking> in
                    return me
                        .fulfillmentNav()
                        .updateUserCredentials(loggedInProvider)
                        .mapReplace(provider)
                }
                .flatMap { provider -> Observable<AuthorizedNetworking> in
                    return me
                        .fulfillmentNav()
                        .updateUserCredentials(loggedInProvider)
                        .mapReplace(provider)
                }
                .flatMap { provider -> Observable<AuthorizedNetworking> in
                    return me
                        .checkForCreditCard(loggedInProvider)
                        .doOnNext { cards in
                            // If the cards list doesn't exist, or its .empty, then perform the segue to collect one.
                            // Otherwise, proceed directly to the loading view controller to place the bid.
                            if cards.isEmpty {
                                me.performSegue(.ArtsyUserviaPINHasNotRegisteredCard)
                            } else {
                                me.performSegue(.PINConfirmedhasCard)
                            }
                        }
                        .mapReplace(provider)
                }
                .map(void)
                .doOnError { error in
                    if let response = (error as NSError).userInfo["data"] as? Response {
                        let responseBody = NSString(data: response.data, encoding: NSUTF8StringEncoding)
                        print("Error authenticating(\(response.statusCode)): \(responseBody)")
                    }

                    me.showAuthenticationError()
                }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        if segue == .ArtsyUserviaPINHasNotRegisteredCard {
            let viewController = segue.destinationViewController as! RegisterViewController
            viewController.provider = provider
        } else if segue == .PINConfirmedhasCard {
            let viewController = segue.destinationViewController as! LoadingViewController
            viewController.provider = provider
        }
    }

    @IBAction func forgotPINTapped(sender: AnyObject) {
        let auctionID = fulfillmentNav().auctionID
        let number = fulfillmentNav().bidDetails.newUser.phoneNumber.value ?? ""
        let endpoint: ArtsyAPI = ArtsyAPI.BidderDetailsNotification(auctionID: auctionID, identifier: number)

        let alertController = UIAlertController(title: "Forgot PIN", message: "We have sent your bidder details to your device.", preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "Back", style: .Cancel) { (_) in }
        alertController.addAction(cancelAction)

        self.presentViewController(alertController, animated: true) {}

        provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .subscribeNext { _ in

                // Necessary to subscribe to the actual observable. This should be in a CocoaAction of the button, instead.
                logger.log("Sent forgot PIN request")
            }
            .addDisposableTo(rx_disposeBag)
    }

    func showAuthenticationError() {
        confirmButton.flashError("Wrong PIN")
        pinTextField.flashForError()
        keypadContainer.resetAction.execute()
    }

    func checkForCreditCard(loggedInProvider: AuthorizedNetworking) -> Observable<[Card]> {
        let endpoint = ArtsyAuthenticatedAPI.MyCreditCards
        return loggedInProvider.request(endpoint).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Card.self)
    }
}

private extension ConfirmYourBidPINViewController {
    @IBAction func dev_loggedInTapped(sender: AnyObject) {
        self.performSegue(.PINConfirmedhasCard)
    }
}