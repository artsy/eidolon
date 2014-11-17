import UIKit

class RegistrationMobileViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {
    
    @IBOutlet var numberTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {
            numberTextField.text = bidDetails.newUser.phoneNumber

            RAC(bidDetails, "newUser.phoneNumber") <~ numberTextField.rac_textSignal()
            
            let numberIsInvalidSignal = RACObserve(bidDetails.newUser, "phoneNumber").map(isZeroLengthString)
            RAC(confirmButton, "enabled") <~ numberIsInvalidSignal.not()
        }

        numberTextField.returnKeySignal().subscribeNext({ [weak self] (_) -> Void in
            self?.finishedSignal.sendCompleted()
            return
        })

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
