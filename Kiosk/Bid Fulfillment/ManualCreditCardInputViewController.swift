import UIKit
import ReactiveCocoa
import Swift_RAC_Macros
import Keys

public class ManualCreditCardInputViewController: UIViewController, RegistrationSubController {
    let finishedSignal = RACSubject()

    @IBOutlet weak var cardNumberTextField: TextField!
    @IBOutlet weak var expirationMonthTextField: TextField!
    @IBOutlet weak public var expirationYearTextField: TextField!

    @IBOutlet weak var expirationDateWrapperView: UIView!
    @IBOutlet weak var cardNumberWrapperView: UIView!
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var cardConfirmButton: ActionButton!
    @IBOutlet weak var dateConfirmButton: ActionButton!

    lazy var keys = EidolonKeys()

    public lazy var viewModel: ManualCreditCardInputViewModel = {
        var bidDetails = self.navigationController?.fulfillmentNav().bidDetails
        return ManualCreditCardInputViewModel(bidDetails: bidDetails, finishedSubject: self.finishedSignal)
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        expirationDateWrapperView.hidden = true

        // We show the enter credit card number, then the date switching the views around
        RAC(viewModel, "cardFullDigits") <~ cardNumberTextField.rac_textSignal()
        RAC(viewModel, "expirationYear") <~ expirationYearTextField.rac_textSignal()
        RAC(viewModel, "expirationMonth") <~ expirationMonthTextField.rac_textSignal()

        RAC(cardConfirmButton, "enabled") <~ viewModel.creditCardNumberIsValidSignal

        dateConfirmButton.rac_command = viewModel.registerButtonCommand()
        RAC(errorLabel, "hidden") <~ dateConfirmButton.rac_command.errors.take(1).mapReplace(false).startWith(true)

        viewModel.moveToYearSignal.take(1).subscribeNext { [weak self] _ -> Void in
            self?.expirationYearTextField.becomeFirstResponder()
            return
        }

        cardNumberTextField.becomeFirstResponder()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return viewModel.isEntryValid(string)
    }

    @IBAction public func cardNumberconfirmTapped(sender: AnyObject) {
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

    public class func instantiateFromStoryboard(storyboard: UIStoryboard) -> ManualCreditCardInputViewController {
        return storyboard.viewControllerWithID(.ManualCardDetailsInput) as! ManualCreditCardInputViewController
    }
}
