import UIKit
import ReactiveCocoa
import Swift_RAC_Macros
import Keys
import Stripe

public class ManualCreditCardInputViewController: UIViewController, RegistrationSubController {
    let finishedSignal = RACSubject()

    @IBOutlet weak var cardNumberTextField: TextField!
    @IBOutlet weak var expirationMonthTextField: TextField!
    @IBOutlet weak var expirationYearTextField: TextField!

    @IBOutlet weak var expirationDateWrapperView: UIView!
    @IBOutlet weak var cardNumberWrapperView: UIView!
    @IBOutlet weak var errorLabel: UILabel!

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

        // We show the enter credit card number, then the date switching the views around

        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {

            RAC(self, "cardFullDigits") <~ cardNumberTextField.rac_textSignal()
            RAC(self, "expirationYear") <~ expirationYearTextField.rac_textSignal()
            RAC(self, "expirationMonth") <~ expirationMonthTextField.rac_textSignal().doNext() { (value) in
                if countElements(value as String) == 2 {
                    self.expirationYearTextField.becomeFirstResponder()
                }
            }

            let numberIsValidSignal = RACObserve(self, "cardFullDigits").map(StripeManager.stringIsCreditCard)
            RAC(cardConfirmButton, "enabled") <~ numberIsValidSignal

            let monthSignal = RACObserve(self, "expirationMonth").map(islessThan3CharLengthString)
            let yearSignal = RACObserve(self, "expirationYear").map(is4CharLengthString)

            let formIsValid = RACSignal.combineLatest([yearSignal, monthSignal]).and()
            dateConfirmButton.rac_command = RACCommand(enabled: formIsValid) { [weak self] _ in
                self?.registerCardSignal(bidDetails.newUser) ?? RACSignal.empty()
            }
        }

        cardNumberTextField.becomeFirstResponder()
    }

    func registerCardSignal(newUser: NewUser) -> RACSignal {
        let month = expirationMonth.toUInt(defaultValue: 0)
        let year = expirationYear.toUInt(defaultValue: 0)

        return StripeManager.registerCard(cardFullDigits, month: month, year: year).doNext() { [weak self] (object) in
            let token = object as STPToken

            newUser.creditCardName = token.card.name
            newUser.creditCardtype = token.card.brand.name
            newUser.creditCardToken = token.tokenId
            newUser.creditCardDigit = token.card.last4

            self?.finishedSignal.sendCompleted()
        }.doError() { [weak self] (_) -> Void in
            self?.errorLabel.hidden = false
            return
        }
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


}
