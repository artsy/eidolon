import UIKit

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
            RAC(confirmButton, "enabled") <~ emailIsValidSignal
        }

        emailTextField.returnKeySignal().subscribeNext({ [weak self] (_) -> Void in
            self?.finishedSignal.sendCompleted()
            return
        })
        
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
