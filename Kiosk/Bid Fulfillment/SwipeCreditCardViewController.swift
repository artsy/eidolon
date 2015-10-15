import UIKit
import Artsy_UILabels
import ReactiveCocoa
import Swift_RAC_Macros
import Keys
import Stripe

class SwipeCreditCardViewController: UIViewController, RegistrationSubController {

    @IBOutlet var cardStatusLabel: ARSerifLabel!
    let finishedSignal = RACSubject()

    @IBOutlet weak var spinner: Spinner!
    @IBOutlet weak var processingLabel: UILabel!
    @IBOutlet weak var illustrationImageView: UIImageView!

    @IBOutlet weak var titleLabel: ARSerifLabel!

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> SwipeCreditCardViewController {
        return storyboard.viewControllerWithID(.RegisterCreditCard) as! SwipeCreditCardViewController
    }

    dynamic var cardName = ""
    dynamic var cardLastDigits = ""
    dynamic var cardToken = ""

    lazy var keys = EidolonKeys()
    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    lazy var appSetup = AppSetup.sharedState
    lazy var cardHandler: CardHandler = {
        if self.appSetup.useStaging {
            return CardHandler(apiKey: self.keys.cardflightStagingAPIClientKey(), accountToken: self.keys.cardflightStagingMerchantAccountToken())
        } else {
            return CardHandler(apiKey: self.keys.cardflightProductionAPIClientKey(), accountToken: self.keys.cardflightProductionMerchantAccountToken())
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInProgress(false)

        cardHandler.cardSwipedSignal.takeUntil(self.viewWillDisappearSignal()).subscribeNext({ (message) -> Void in
            let message = message as! String
            self.cardStatusLabel.text = "Card Status: \(message)"
            if message == "Got Card" {
                self.setInProgress(true)
            }

            if message.hasPrefix("Card Flight Error") {
                self.processingLabel.text = "ERROR PROCESSING CARD - SEE ADMIN"
            }


        }, error: { (error) -> Void in
            self.cardStatusLabel.text = "Card Status: Errored"
            self.setInProgress(false)
            self.titleLabel.text = "Please Swipe a Valid Credit Card"
            self.titleLabel.textColor = .artsyRed()

        }, completed: {
            self.cardStatusLabel.text = "Card Status: completed"

            if let card = self.cardHandler.card {
                self.cardName = card.name
                self.cardLastDigits = card.encryptedSwipedCardNumber

                self.cardToken = card.cardToken

                // TODO: RACify this
                if let newUser = self.navigationController?.fulfillmentNav().bidDetails.newUser {
                    newUser.name = (newUser.name == "" || newUser.name == nil) ? card.name : newUser.name
                }
            }

            self.cardHandler.end()
            self.finishedSignal.sendCompleted()
        })
        cardHandler.startSearching()

        RAC(bidDetails, "newUser.creditCardName") <~ RACObserve(self, "cardName").takeUntil(viewWillDisappearSignal())
        RAC(bidDetails, "newUser.creditCardDigit") <~ RACObserve(self, "cardLastDigits").takeUntil(viewWillDisappearSignal())
        RAC(bidDetails, "newUser.creditCardToken") <~ RACObserve(self, "cardToken").takeUntil(viewWillDisappearSignal())
        bidDetails.newUser.swipedCreditCard = true
    }

    func setInProgress(show: Bool) {
        illustrationImageView.alpha = show ? 0.1 : 1
        processingLabel.hidden = !show
        spinner.hidden = !show
    }

    // Used only for development, in private extension for testing.
    private lazy var stripeManager = StripeManager()
}

private extension SwipeCreditCardViewController {
    func applyCardWithSuccess(success: Bool) {
        let cardFullDigits = success ? "4242424242424242" : "4000000000000002"

        stripeManager.registerCard(cardFullDigits, month: 04, year: 2018, securityCode: "123", postalCode: "10013").subscribeNext() { [weak self] (object) in
            let token = object as! STPToken

            self?.cardName = "Kiosk Staging CC Test"
            self?.cardToken = token.tokenId
            self?.cardLastDigits = token.card.last4

            if let newUser = self?.navigationController?.fulfillmentNav().bidDetails.newUser {
                newUser.name = token.card.brand.name
            }

            self?.finishedSignal.sendCompleted()
        }
    }

    @IBAction func dev_creditCardOKTapped(sender: AnyObject) {
        applyCardWithSuccess(true)
    }

    @IBAction func dev_creditCardFailTapped(sender: AnyObject) {
        applyCardWithSuccess(false)
    }
}
