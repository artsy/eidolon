import UIKit
import ReactiveCocoa
import Swift_RAC_Macros

class RegistrationPostalZipViewController: UIViewController, RegistrationSubController {
    
    @IBOutlet var zipCodeTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {
            zipCodeTextField.text = bidDetails.newUser.zipCode
            RAC(bidDetails, "newUser.zipCode") <~ zipCodeTextField.rac_textSignal()
            
            let zipCodeIsValidSignal = RACObserve(bidDetails.newUser, "zipCode").map(isZeroLengthString).not()
            confirmButton.rac_command = RACCommand(enabled: zipCodeIsValidSignal) { [weak self] _ -> RACSignal! in
                self?.finishedSignal.sendCompleted()
                return RACSignal.empty()
            }
        }

        zipCodeTextField.returnKeySignal().subscribeNext({ [weak self] (_) -> Void in
            self?.confirmButton.rac_command.execute(nil)
            return
        })
        zipCodeTextField.becomeFirstResponder()
    }

    @IBAction func confirmTapped(sender: AnyObject) {
        finishedSignal.sendCompleted()
    }
}
