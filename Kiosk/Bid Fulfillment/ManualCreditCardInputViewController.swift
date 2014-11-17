import UIKit

public class ManualCreditCardInputViewController: UIViewController, RegistrationSubController {
    let finishedSignal = RACSubject()

    var balancedHandler: BalancedManager!

    @IBOutlet weak var cardNumberTextField: TextField!
    @IBOutlet weak var expirationMonthTextField: TextField!
    @IBOutlet weak var expirationYearTextField: TextField!

    @IBOutlet weak var expirationDateWrapperView: UIView!
    @IBOutlet weak var cardNumberWrapperView: UIView!
    @IBOutlet weak var errorLabel: UILabel!


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

        let marketplace = AppSetup.sharedState.useStaging ? keys.balancedMarketplaceStagingToken() : keys.balancedMarketplaceToken()
        balancedHandler = BalancedManager(marketplace: marketplace)

        RAC(self, "cardName") <~ RACObserve(balancedHandler, "cardName")
        RAC(self, "cardToken") <~ RACObserve(balancedHandler, "cardToken")
        RAC(self, "cardLastDigits") <~ RACObserve(balancedHandler, "cardLastDigits")

        // We show the enter credit card number, then the date switchign the views around

        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {

            RAC(bidDetails, "newUser.creditCardName") <~ RACObserve(self, "cardName")
            RAC(bidDetails, "newUser.creditCardToken") <~ RACObserve(self, "cardToken")
            RAC(bidDetails, "newUser.creditCardDigit") <~ RACObserve(self, "cardLastDigits")

            RAC(self, "cardFullDigits") <~ cardNumberTextField.rac_textSignal()
            RAC(self, "expirationYear") <~ expirationYearTextField.rac_textSignal()
            RAC(self, "expirationMonth") <~ expirationMonthTextField.rac_textSignal().doNext() { (value) in
                if countElements(value as String) == 2 {
                    self.expirationYearTextField.becomeFirstResponder()
                }
            }

            let numberIsValidSignal = RACObserve(self, "cardFullDigits").map(stringIsCreditCard)
            RAC(cardConfirmButton, "enabled") <~ numberIsValidSignal

            let monthSignal = RACObserve(self, "expirationMonth").map(islessThan3CharLengthString)
            let yearSignal = RACObserve(self, "expirationYear").map(is4CharLengthString)

            let formIsValid = RACSignal.combineLatest([yearSignal, monthSignal]).and()
            dateConfirmButton.rac_command = RACCommand(enabled: formIsValid) { [weak self] _ in
                self?.registerCardSignal() ?? RACSignal.empty()
            }
        }

        cardNumberTextField.becomeFirstResponder()
    }

    func registerCardSignal() -> RACSignal {
        let month = expirationMonth.toInt() ?? 0
        let year = expirationYear.toInt() ?? 0

        return balancedHandler.registerCard(cardFullDigits, month: month, year: year).doNext() { [weak self] (_) in
            self?.finishedSignal.sendCompleted()
            return

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
