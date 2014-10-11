import UIKit

class RegistrationPostalZipViewController: UIViewController, RegistrationSubController {
    
    @IBOutlet var zipCodeTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bidDetails = self.navigationController?.fulfilmentNav().bidDetails {
            
            RAC(bidDetails.newUser, "zipCode") <~ zipCodeTextField.rac_textSignal()
            
            let emailIsValidSignal = RACObserve(bidDetails.newUser, "zipCode").map(isZeroLengthString)
            RAC(confirmButton, "enabled") <~ emailIsValidSignal.notEach()
        }

    }
    
    let finishedSignal = RACSubject()
    @IBAction func confirmTapped(sender: AnyObject) {
        finishedSignal.sendCompleted()
    }
}
