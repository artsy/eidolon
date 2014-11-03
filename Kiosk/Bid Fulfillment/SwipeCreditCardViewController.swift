import UIKit

public class SwipeCreditCardViewController: UIViewController, RegistrationSubController {

    @IBOutlet var cardStatusLabel: ARSerifLabel!
    let finishedSignal = RACSubject()

    @IBOutlet weak var spinner: Spinner!
    @IBOutlet weak var processingLabel: UILabel!
    @IBOutlet weak var illustrationImageView: UIImageView!

    @IBOutlet weak var titleLabel: ARSerifLabel!

    public class func instantiateFromStoryboard() -> SwipeCreditCardViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.RegisterCreditCard) as SwipeCreditCardViewController
    }

    dynamic var cardName = ""
    dynamic var cardLastDigits = ""
    dynamic var cardToken = ""

    lazy var keys = EidolonKeys()

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setInProgress(false)

        let merchantToken = AppSetup.sharedState.useStaging ? self.keys.cardflightMerchantAccountStagingToken() : self.keys.cardflightMerchantAccountToken()
        let cardHandler = CardHandler(apiKey: self.keys.cardflightAPIClientKey(), accountToken:merchantToken)

        cardHandler.cardSwipedSignal.subscribeNext({ (message) -> Void in
            let message = message as String
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
            self.titleLabel.textColor = UIColor.artsyRed()

        }, completed: {
            self.cardStatusLabel.text = "Card Status: completed"

            if let card = cardHandler.card {
                self.cardName = card.name
                self.cardLastDigits = card.encryptedSwipedCardNumber

                if AppSetup.sharedState.useStaging {
                    self.cardToken = "/v1/marketplaces/TEST-MP7Fs9XluC54HnVAvBKSI3jQ/cards/CC1AF3Ood4u5GdLz4krD8upG"
                } else {
                    self.cardToken = card.cardToken
                }

                // TODO: RACify this
                if let newUser = self.navigationController?.fulfillmentNav().bidDetails.newUser {
                    newUser.name = (newUser.name == "") ? card.name : newUser.name
                }
            }

            cardHandler.end()
            self.finishedSignal.sendCompleted()
        })
        cardHandler.startSearching()
        
        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {
            RAC(bidDetails, "newUser.creditCardName") <~ RACObserve(self, "cardName")
            RAC(bidDetails, "newUser.creditCardDigit") <~ RACObserve(self, "cardLastDigits")
            RAC(bidDetails, "newUser.creditCardToken") <~ RACObserve(self, "cardToken")
        }
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
