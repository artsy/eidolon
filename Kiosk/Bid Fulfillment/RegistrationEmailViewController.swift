import UIKit
import Swift_RAC_Macros
import ReactiveCocoa

public class RegistrationEmailViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {

    @IBOutlet var emailTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()

    public lazy var viewModel: GenericFormValidationViewModel = {
        let emailIsValidSignal = self.emailTextField.rac_textSignal().map(stringIsEmailAddress)
        return GenericFormValidationViewModel(isValidSignal: emailIsValidSignal, manualInvocationSignal: self.emailTextField.returnKeySignal(), finishedSubject: self.finishedSignal)
    }()

    public lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    public override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.text = bidDetails.newUser.email
        RAC(bidDetails, "newUser.email") <~ emailTextField.rac_textSignal().takeUntil(viewWillDisappearSignal())
        confirmButton.rac_command = viewModel.command

        emailTextField.becomeFirstResponder()
    }

    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if (string.isEmpty) { return true }

        // the API doesn't accept spaces
        return string != " "
    }

    public class func instantiateFromStoryboard(storyboard: UIStoryboard) -> RegistrationEmailViewController {
        return storyboard.viewControllerWithID(.RegisterEmail) as! RegistrationEmailViewController
    }
}
