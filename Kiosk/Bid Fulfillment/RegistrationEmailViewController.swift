import UIKit

class RegistrationEmailViewController: UIViewController, RegistrationSubController {

    @IBOutlet var emailTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let bidDetails = self.navigationController?.fulfilmentNav().bidDetails {

            RAC(bidDetails, "newUser.email") <~ emailTextField.rac_textSignal()

            let emailIsValidSignal = RACObserve(bidDetails.newUser, "email").map(stringIsEmailAddress)
            RAC(confirmButton, "enabled") <~ emailIsValidSignal.notEach()
        }
    }

    let finishedSignal = RACSubject()
    @IBAction func confirmTapped(sender: AnyObject) {
        finishedSignal.sendCompleted()
    }
}
