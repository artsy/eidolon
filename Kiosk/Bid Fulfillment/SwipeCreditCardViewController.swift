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
    lazy var cardHandler:CardHandler = CardHandler(apiKey: self.keys.cardflightAPIClientKey(), accountToken: self.keys.cardflightMerchantAccountToken())

    public override func viewDidLoad() {
        super.viewDidLoad()

        cardHandler.cardSwipedSignal.subscribeNext({ [unowned self] (message) -> Void in
            self.cardStatusLabel.text = "Card Status: \(message)"

        }, error: { [unowned self] (error) -> Void in
            self.cardStatusLabel.text = "Card Status: Errored"

        }, completed: { [unowned self] () -> Void in
            self.cardStatusLabel.text = "Card Status: completed"

            if let card = self.cardHandler.card {
                self.cardName = card.name
                self.cardLastDigits = card.encryptedSwipedCardNumber
                self.cardToken = card.cardToken
            }

            self.finishedSignal.sendCompleted()
        })
        cardHandler.startSearching()
        
        if let bidDetails = self.navigationController?.fulfilmentNav().bidDetails {
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
