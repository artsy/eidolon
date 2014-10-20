import UIKit

public class SwipeCreditCardViewController: UIViewController, RegistrationSubController {

    @IBOutlet var cardStatusLabel: ARSerifLabel!
    let finishedSignal = RACSubject()

    public class func instantiateFromStoryboard() -> SwipeCreditCardViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.RegisterCreditCard) as SwipeCreditCardViewController
    }

    dynamic var cardName = ""
    dynamic var cardLastDigits = ""
    dynamic var cardToken = ""

    lazy var keys = EidolonKeys()

    public override func viewDidLoad() {
        super.viewDidLoad()

        let merchantToken = AppSetup.sharedState.useStaging ? self.keys.cardflightMerchantAccountStagingToken() : self.keys.cardflightMerchantAccountToken()
        let cardHandler = CardHandler(apiKey: self.keys.cardflightAPIClientKey(), accountToken:merchantToken)

        // This will cause memory leaks if signals are not completed.
        
        cardHandler.cardSwipedSignal.subscribeNext({ (message) -> Void in
            self.cardStatusLabel.text = "Card Status: \(message)"

        }, error: { (error) -> Void in
            self.cardStatusLabel.text = "Card Status: Errored"

        }, completed: { () -> Void in
            self.cardStatusLabel.text = "Card Status: completed"

            if let card = cardHandler.card {
                self.cardName = card.name
                self.cardLastDigits = card.encryptedSwipedCardNumber

                if AppSetup.sharedState.useStaging {
                    self.cardToken = "/v1/marketplaces/TEST-MP7Fs9XluC54HnVAvBKSI3jQ/cards/CC1AF3Ood4u5GdLz4krD8upG"
                } else {
                    self.cardToken = card.cardToken
                }

            }

            self.finishedSignal.sendCompleted()
        })
        cardHandler.startSearching()
        
        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {
            RAC(bidDetails, "newUser.creditCardName") <~ RACObserve(self, "cardName")
            RAC(bidDetails, "newUser.creditCardDigit") <~ RACObserve(self, "cardLastDigits")
            RAC(bidDetails, "newUser.creditCardToken") <~ RACObserve(self, "cardToken")
        }
    }
}

private extension SwipeCreditCardViewController {
    @IBAction func dev_creditCradOKTapped(sender: AnyObject) {
        self.cardName = "MRS DEV"
        self.cardLastDigits = "2323"
        self.cardToken = "3223423423423"

        self.finishedSignal.sendCompleted()
    }
}
