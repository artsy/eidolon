import UIKit
import ReactiveCocoa
import Swift_RAC_Macros

class RegistrationPostalZipViewController: UIViewController, RegistrationSubController {
    @IBOutlet var zipCodeTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()

    lazy var viewModel: GenericFormValidationViewModel = {
        let zipCodeIsValidSignal = self.zipCodeTextField.rac_textSignal().map(isZeroLengthString).not()
        return GenericFormValidationViewModel(isValidSignal: zipCodeIsValidSignal, manualInvocationSignal: self.zipCodeTextField.returnKeySignal(), finishedSubject: self.finishedSignal)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {
            zipCodeTextField.text = bidDetails.newUser.zipCode
            RAC(bidDetails, "newUser.zipCode") <~ zipCodeTextField.rac_textSignal()
            confirmButton.rac_command = viewModel.command
        }

        zipCodeTextField.becomeFirstResponder()
    }
}
