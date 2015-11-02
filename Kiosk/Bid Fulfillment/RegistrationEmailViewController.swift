import UIKit
import ReactiveCocoa

class RegistrationEmailViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {

    @IBOutlet var emailTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()

    lazy var viewModel: GenericFormValidationViewModel = {
        let emailIsValidSignal = self.emailTextField.rac_textSignal().map(stringIsEmailAddress)
        return GenericFormValidationViewModel(isValidSignal: emailIsValidSignal, manualInvocationSignal: self.emailTextField.returnKeySignal(), finishedSubject: self.finishedSignal)
    }()

    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.text = bidDetails.newUser.email
        RAC(bidDetails, "newUser.email") <~ emailTextField.rac_textSignal().takeUntil(viewWillDisappearSignal())
        confirmButton.rac_command = viewModel.command

        emailTextField.becomeFirstResponder()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if (string.isEmpty) { return true }

        // the API doesn't accept spaces
        return string != " "
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> RegistrationEmailViewController {
        return storyboard.viewControllerWithID(.RegisterEmail) as! RegistrationEmailViewController
    }
}
