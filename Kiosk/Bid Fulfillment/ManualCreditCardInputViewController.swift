import UIKit
import ReactiveCocoa
import Swift_RAC_Macros
import Keys

class ManualCreditCardInputViewController: UIViewController, RegistrationSubController {
    let finishedSignal = RACSubject()

    @IBOutlet weak var cardNumberTextField: TextField!
    @IBOutlet weak var expirationMonthTextField: TextField!
    @IBOutlet weak var expirationYearTextField: TextField!

    @IBOutlet weak var expirationDateWrapperView: UIView!
    @IBOutlet weak var cardNumberWrapperView: UIView!
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var cardConfirmButton: ActionButton!
    @IBOutlet weak var dateConfirmButton: ActionButton!

    lazy var keys = EidolonKeys()

    lazy var viewModel: ManualCreditCardInputViewModel = {
        var bidDetails = self.navigationController?.fulfillmentNav().bidDetails
        return ManualCreditCardInputViewModel(bidDetails: bidDetails, finishedSubject: self.finishedSignal)
    }()

    override func viewDidLoad() {
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

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> ManualCreditCardInputViewController {
        return storyboard.viewControllerWithID(.ManualCardDetailsInput) as! ManualCreditCardInputViewController
    }
}

private extension ManualCreditCardInputViewController {
    func applyCardWithSuccess(success: Bool) {
        cardNumberTextField.text = success ? "4242424242424242" : "4000000000000002"
        cardNumberTextField.sendActionsForControlEvents(.AllEditingEvents)
        cardConfirmButton.sendActionsForControlEvents(.TouchUpInside)

        expirationMonthTextField.text = "04"
        expirationMonthTextField.sendActionsForControlEvents(.AllEditingEvents)
        expirationYearTextField.text = "2018"
        expirationYearTextField.sendActionsForControlEvents(.AllEditingEvents)
        dateConfirmButton.sendActionsForControlEvents(.TouchUpInside)
    }

    @IBAction func dev_creditCardOKTapped(sender: AnyObject) {
        applyCardWithSuccess(true)
    }

    @IBAction func dev_creditCardFailTapped(sender: AnyObject) {
        applyCardWithSuccess(false)
    }
}