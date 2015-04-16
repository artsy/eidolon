import UIKit
import ReactiveCocoa
import Swift_RAC_Macros

class RegistrationMobileViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {
    
    @IBOutlet var numberTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {
            numberTextField.text = bidDetails.newUser.phoneNumber

            RAC(bidDetails, "newUser.phoneNumber") <~ numberTextField.rac_textSignal()
            
            let numberIsValidSignal = RACObserve(bidDetails.newUser, "phoneNumber").map(isZeroLengthString).not()
            
            confirmButton.rac_command = RACCommand(enabled: numberIsValidSignal) { [weak self] _ -> RACSignal! in
                self?.finishedSignal.sendCompleted()
                return RACSignal.empty()
            }
        }

        numberTextField.returnKeySignal().subscribeNext { [weak self] (_) -> Void in
            self?.confirmButton.rac_command.execute(nil)
            return
        }

        numberTextField.becomeFirstResponder()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if (countElements(string) == 0) { return true }

        // the API doesn't accept chars
        let notNumberChars = NSCharacterSet.decimalDigitCharacterSet().invertedSet;
        return countElements(string.stringByTrimmingCharactersInSet(notNumberChars)) != 0
    }

    @IBAction func confirmTapped(sender: AnyObject) {
        finishedSignal.sendCompleted()
    }
}
