import UIKit
import ReactiveCocoa
import Swift_RAC_Macros

class RegistrationMobileViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {
    
    @IBOutlet var numberTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()

    lazy var viewModel: GenericFormValidationViewModel = {
        let numberIsValidSignal = self.numberTextField.rac_textSignal().map(isZeroLengthString).not()
        return GenericFormValidationViewModel(isValidSignal: numberIsValidSignal, manualInvocationSignal: self.numberTextField.returnKeySignal(), finishedSubject: self.finishedSignal)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {
            numberTextField.text = bidDetails.newUser.phoneNumber
            RAC(bidDetails, "newUser.phoneNumber") <~ numberTextField.rac_textSignal()
            confirmButton.rac_command = viewModel.command
        }

        numberTextField.becomeFirstResponder()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if (countElements(string) == 0) { return true }

        // the API doesn't accept chars
        let notNumberChars = NSCharacterSet.decimalDigitCharacterSet().invertedSet;
        return countElements(string.stringByTrimmingCharactersInSet(notNumberChars)) != 0
    }
}
