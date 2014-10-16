import UIKit

class RegistrationMobileViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {
    
    @IBOutlet var numberTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let bidDetails = self.navigationController?.fulfilmentNav().bidDetails {
            RAC(bidDetails, "newUser.phoneNumber") <~ numberTextField.rac_textSignal()
            
            let numberIsInvalidSignal = RACObserve(bidDetails.newUser, "phoneNumber").map(isZeroLengthString)
            RAC(confirmButton, "enabled") <~ numberIsInvalidSignal.notEach()
        }
        
        numberTextField.becomeFirstResponder()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // the API doesn't accept chars
        let notNumberChars = NSCharacterSet.decimalDigitCharacterSet().invertedSet;
        return countElements(string.stringByTrimmingCharactersInSet(notNumberChars)) != 0
    }


    let finishedSignal = RACSubject()
    @IBAction func confirmTapped(sender: AnyObject) {
        finishedSignal.sendCompleted()
    }
}
