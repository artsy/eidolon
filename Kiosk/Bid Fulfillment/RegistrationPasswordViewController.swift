import UIKit

class RegistrationPasswordViewController: UIViewController, RegistrationSubController {

    @IBOutlet var passwordTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let bidDetails = self.navigationController?.fulfilmentNav()?.bidDetails {

            RAC(bidDetails.newUser, "password") <~ passwordTextField.rac_textSignal()

            let longerThan4CharSignal = RACObserve(bidDetails.newUser, "password").map(longerThan4CharString)
            RAC(confirmButton, "enabled") <~ longerThan4CharSignal
        }
    }

    let finishedSignal = RACSubject()
    @IBAction func confirmTapped(sender: AnyObject) {
        finishedSignal.sendCompleted()
    }
}
