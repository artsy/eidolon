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
    lazy var cardHandler:CardHandler = CardHandler(apiKey: self.keys.cardflightTestAPIClientKey(), accountToken: self.keys.cardflightMerchantAccountToken())

    public override func viewDidLoad() {
        super.viewDidLoad()

        cardHandler.cardSwipedSignal.subscribeNext({ [unowned self] (message) -> Void in
            self.cardStatusLabel.text = "Card Status: \(message)"

        }, error: { [unowned self] (error) -> Void in
            self.cardStatusLabel.text = "Card Status: Errored"

        }, completed: { [unowned self] () -> Void in
            self.cardStatusLabel.text = "Card Status: completed"
            self.cardName = cardHandler.card?.name
            self.cardLastDigits = cardHandler.card?.last4
            self.cardToken = cardHandler.card?.cardToken

            self.finishedSignal.sendCompleted()
        })
        cardHandler.startSearching()

        if let bidDetails = self.navigationController?.fulfilmentNav()?.bidDetails {
            RAC(bidDetails, "bidAmountCents") <~ RACObserve(self, "bidDollars").map { return ($0 as Float * 100) }
        }
    }

    @IBAction func dev_creditCradOKTapped(sender: AnyObject) {

        self.finishedSignal.sendCompleted()
    }
}
