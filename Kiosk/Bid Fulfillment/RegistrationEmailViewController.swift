import UIKit
import Swift_RAC_Macros
import ReactiveCocoa

class RegistrationEmailViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {

    @IBOutlet var emailTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {
            emailTextField.text = bidDetails.newUser.email

            RAC(bidDetails, "newUser.email") <~ emailTextField.rac_textSignal()

            let emailIsValidSignal = RACObserve(bidDetails.newUser, "email").map(stringIsEmailAddress)
            confirmButton.rac_command = RACCommand(enabled: emailIsValidSignal) { [weak self] _ -> RACSignal! in
                self?.finishedSignal.sendCompleted()
                return RACSignal.empty()
            }
        }

        emailTextField.returnKeySignal().subscribeNext { [weak self] (_) -> Void in
            self?.confirmButton.rac_command.execute(nil)
            return
        }
        
        emailTextField.becomeFirstResponder()
    }

    @IBAction func confirmTapped(sender: AnyObject) {
        finishedSignal.sendCompleted()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if (countElements(string) == 0) { return true }

        // the API doesn't accept spaces
        return string != " "
    }

}
