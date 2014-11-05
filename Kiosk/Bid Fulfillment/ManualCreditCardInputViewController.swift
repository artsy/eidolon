import UIKit

public class ManualCreditCardInputViewController: UIViewController, RegistrationSubController {
    let finishedSignal = RACSubject()

    @IBOutlet weak var cardNumberTextField: TextField!
    @IBOutlet weak var expirationMonthTextField: TextField!
    @IBOutlet weak var expirationYearTextField: TextField!

    @IBOutlet weak var expirationDateWrapperView: UIView!
    @IBOutlet weak var cardNumberWrapperView: UIView!

    dynamic var cardName = ""
    dynamic var cardLastDigits = ""
    dynamic var cardToken = ""

    dynamic var cardFullDigits = ""
    dynamic var expirationMonth = ""
    dynamic var expirationYear = ""

    @IBOutlet weak var cardConfirmButton: ActionButton!
    @IBOutlet weak var dateConfirmButton: ActionButton!

    lazy var keys = EidolonKeys()

    public override func viewDidLoad() {
        super.viewDidLoad()
        expirationDateWrapperView.hidden = true

        // We show the enter credit card number, then the date switchign the views around

        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {

            RAC(bidDetails, "newUser.creditCardName") <~ RACObserve(self, "cardName")
            RAC(bidDetails, "newUser.creditCardToken") <~ RACObserve(self, "cardToken")
            RAC(bidDetails, "newUser.creditCardDigit") <~ RACObserve(self, "cardLastDigits")

            RAC(self, "cardFullDigits") <~ cardNumberTextField.rac_textSignal()
            RAC(self, "expirationMonth") <~ expirationMonthTextField.rac_textSignal()
            RAC(self, "expirationYear") <~ expirationYearTextField.rac_textSignal()

            let numberIsValidSignal = RACObserve(self, "cardFullDigits").map(stringIsCreditCard)
            RAC(cardConfirmButton, "enabled") <~ numberIsValidSignal

            let monthSignal = RACObserve(self, "expirationMonth").map(islessThan3CharLengthString)
            let yearSignal = RACObserve(self, "expirationYear").map(is4CharLengthString)

            RAC(dateConfirmButton, "enabled") <~ RACSignal.combineLatest([yearSignal, monthSignal]).reduceAnd()
        }

        cardNumberTextField.becomeFirstResponder()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if (countElements(string) == 0) { return true }

        // the API doesn't accept chars
        let notNumberChars = NSCharacterSet.decimalDigitCharacterSet().invertedSet;
        return countElements(string.stringByTrimmingCharactersInSet(notNumberChars)) != 0
    }

    @IBAction func cardNumberconfirmTapped(sender: AnyObject) {
        cardNumberWrapperView.hidden = true
        expirationDateWrapperView.hidden = false

        expirationDateWrapperView.frame = CGRectMake(0, 0, CGRectGetWidth(expirationDateWrapperView.frame), CGRectGetHeight(expirationDateWrapperView.frame))

        expirationMonthTextField.becomeFirstResponder()
    }

    @IBAction func backToCardNumber(sender: AnyObject) {
        cardNumberWrapperView.hidden = false
        expirationDateWrapperView.hidden = true

        cardNumberTextField.becomeFirstResponder()
    }

    @IBAction func confirmTapped(sender: AnyObject) {
        
        let month = expirationMonth.toInt() ?? 0
        let year = expirationYear.toInt() ?? 0

        let card = BPCard(number: cardFullDigits, expirationMonth: UInt(month), expirationYear: UInt(year), optionalFields: nil)

        let marketplace = AppSetup.sharedState.useStaging ? keys.balancedMarketplaceStagingToken() : keys.balancedMarketplaceToken()

        let balanced = Balanced(marketplaceURI:"/v1/marketplaces/\(marketplace)")

        balanced.tokenizeCard(card, onSuccess: { (dict) -> Void in
            if let data = dict["data"] as? [String: AnyObject] {

                // TODO: We don't capture names

                if let uri = data["uri"] as? String {
                    self.cardToken = uri
                }

                if let last4 = data["last_four"] as? String {
                    self.cardLastDigits = last4
                }

                self.cardName = data["name"] as? String ?? ""
                self.finishedSignal.sendCompleted()
            }

        }) { (error) -> Void in
            logger.error("Error tokenizing via balanced: \(error)")
            return
        }
    }
}
