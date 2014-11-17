import UIKit

class RegistrationPostalZipViewController: UIViewController, RegistrationSubController {
    
    @IBOutlet var zipCodeTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {
            zipCodeTextField.text = bidDetails.newUser.zipCode
            RAC(bidDetails, "newUser.zipCode") <~ zipCodeTextField.rac_textSignal()
            
            let emailIsValidSignal = RACObserve(bidDetails.newUser, "zipCode").map(isZeroLengthString)
            RAC(confirmButton, "enabled") <~ emailIsValidSignal.not()
        }


        zipCodeTextField.returnKeySignal().subscribeNext({ [weak self] (_) -> Void in
            self?.finishedSignal.sendCompleted()
            return
        })
        zipCodeTextField.becomeFirstResponder()
    }

    @IBAction func confirmTapped(sender: AnyObject) {
        finishedSignal.sendCompleted()
    }
}
