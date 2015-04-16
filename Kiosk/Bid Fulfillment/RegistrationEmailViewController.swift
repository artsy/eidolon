import UIKit
import Swift_RAC_Macros
import ReactiveCocoa

class RegistrationEmailViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {

    @IBOutlet var emailTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()

    lazy var viewModel: GenericFormValidationViewModel = {
        let emailIsValidSignal = self.emailTextField.rac_textSignal().map(stringIsEmailAddress)
        return GenericFormValidationViewModel(isValidSignal: emailIsValidSignal, manualInvocationSignal: self.emailTextField.returnKeySignal(), finishedSubject: self.finishedSignal)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {
            emailTextField.text = bidDetails.newUser.email
            RAC(bidDetails, "newUser.email") <~ emailTextField.rac_textSignal()
            confirmButton.rac_command = viewModel.command
        }
        
        emailTextField.becomeFirstResponder()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if (countElements(string) == 0) { return true }

        // the API doesn't accept spaces
        return string != " "
    }

}
