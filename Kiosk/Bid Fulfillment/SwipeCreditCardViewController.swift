import UIKit
import Artsy_UILabels
import ReactiveCocoa
import Swift_RAC_Macros
import Keys

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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInProgress(false)

        let cardHandler: CardHandler
        if AppSetup.sharedState.useStaging {
            cardHandler = CardHandler(apiKey: self.keys.cardflightStagingAPIClientKey(), accountToken: self.keys.cardflightStagingMerchantAccountToken())
        } else {
            cardHandler = CardHandler(apiKey: self.keys.cardflightProductionAPIClientKey(), accountToken: self.keys.cardflightProductionMerchantAccountToken())
        }

        cardHandler.cardSwipedSignal.subscribeNext({ (message) -> Void in
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

            if let card = cardHandler.card {
                self.cardName = card.name
                self.cardLastDigits = card.encryptedSwipedCardNumber

                self.cardToken = card.cardToken

                // TODO: RACify this
                if let newUser = self.navigationController?.fulfillmentNav().bidDetails.newUser {
                    newUser.name = (newUser.name == "" || newUser.name == nil) ? card.name : newUser.name
                }
            }

            cardHandler.end()
            self.finishedSignal.sendCompleted()
        })
        cardHandler.startSearching()

        RAC(bidDetails, "newUser.creditCardName") <~ RACObserve(self, "cardName").takeUntil(viewWillDisappearSignal())
        RAC(bidDetails, "newUser.creditCardDigit") <~ RACObserve(self, "cardLastDigits").takeUntil(viewWillDisappearSignal())
        RAC(bidDetails, "newUser.creditCardToken") <~ RACObserve(self, "cardToken").takeUntil(viewWillDisappearSignal())
    }

    func setInProgress(show: Bool) {
        illustrationImageView.alpha = show ? 0.1 : 1
        processingLabel.hidden = !show
        spinner.hidden = !show
    }
}

private extension SwipeCreditCardViewController {
    @IBAction func dev_creditCradOKTapped(sender: AnyObject) {
        self.cardName = "KIOSK SKIPPED CARD CHECK"
        self.cardLastDigits = "2323"
        self.cardToken = "3223423423423"

        self.finishedSignal.sendCompleted()
    }
}
