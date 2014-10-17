import UIKit

class RegistrationPasswordViewController: UIViewController, RegistrationSubController {

    @IBOutlet var passwordTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {

            let passwordTextSignal = passwordTextField.rac_textSignal()
            RAC(bidDetails, "newUser.password") <~ passwordTextSignal

            RAC(confirmButton, "enabled") <~ passwordTextSignal.map(minimum6CharString)
        }
        
        passwordTextField.becomeFirstResponder()
    }

    let finishedSignal = RACSubject()
    @IBAction func confirmTapped(sender: AnyObject) {
        finishedSignal.sendCompleted()
    }
}
