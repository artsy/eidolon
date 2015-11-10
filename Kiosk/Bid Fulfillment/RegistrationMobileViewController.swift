import UIKit
import RxSwift

class RegistrationMobileViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {
    
    @IBOutlet var numberTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()

    lazy var viewModel: GenericFormValidationViewModel = {
        let numberIsValidSignal = self.numberTextField.rac_textSignal().map(isZeroLengthString).not()
        return GenericFormValidationViewModel(isValidSignal: numberIsValidSignal, manualInvocationSignal: self.numberTextField.returnKeySignal(), finishedSubject: self.finishedSignal)
    }()

    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        numberTextField.text = bidDetails.newUser.phoneNumber
        RAC(bidDetails, "newUser.phoneNumber") <~ numberTextField.rac_textSignal().takeUntil(viewWillDisappearSignal())
        confirmButton.rac_command = viewModel.command

        numberTextField.becomeFirstResponder()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if string.isEmpty { return true }

        // the API doesn't accept chars
        let notNumberChars = NSCharacterSet.decimalDigitCharacterSet().invertedSet;
        return string.stringByTrimmingCharactersInSet(notNumberChars).isNotEmpty
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> RegistrationMobileViewController {
        return storyboard.viewControllerWithID(.RegisterMobile) as! RegistrationMobileViewController
    }
}
