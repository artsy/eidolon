import UIKit
import ReactiveCocoa
import Swift_RAC_Macros

public class RegistrationMobileViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {
    
    @IBOutlet var numberTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()

    lazy var viewModel: GenericFormValidationViewModel = {
        let numberIsValidSignal = self.numberTextField.rac_textSignal().map(isZeroLengthString).not()
        return GenericFormValidationViewModel(isValidSignal: numberIsValidSignal, manualInvocationSignal: self.numberTextField.returnKeySignal(), finishedSubject: self.finishedSignal)
    }()

    public lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    public override func viewDidLoad() {
        super.viewDidLoad()

        numberTextField.text = bidDetails.newUser.phoneNumber
        RAC(bidDetails, "newUser.phoneNumber") <~ numberTextField.rac_textSignal().takeUntil(viewWillDisappearSignal())
        confirmButton.rac_command = viewModel.command

        numberTextField.becomeFirstResponder()
    }

    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if (count(string) == 0) { return true }

        // the API doesn't accept chars
        let notNumberChars = NSCharacterSet.decimalDigitCharacterSet().invertedSet;
        return count(string.stringByTrimmingCharactersInSet(notNumberChars)) != 0
    }

    public class func instantiateFromStoryboard(storyboard: UIStoryboard) -> RegistrationMobileViewController {
        return storyboard.viewControllerWithID(.RegisterMobile) as! RegistrationMobileViewController
    }
}
