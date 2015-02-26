import UIKit

extension UIViewController {
    func promptForBidderDetailsRetrieval() {
        let alertController = UIAlertController.emailPromptAlertViewController() { (email: String) -> () in
            self.receivedEmail(email)
        }
        presentViewController(alertController, animated: true, completion: nil)
    }

    func receivedEmail(email: String) {
        // TODO: API call. 
    }
}

extension UIAlertController {
    class func emailPromptAlertViewController(callback: (String) -> ()) -> Self {
        let alertController = self(title: "Send Bidder Details", message: "Enter your email address registered with Artsy and we will send your bidder number and PIN.", preferredStyle: .Alert)

        var inputTextField: UITextField!

        let ok = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
            callback(inputTextField.text)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }

        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            inputTextField = textField
        }
        alertController.addAction(ok)
        alertController.addAction(cancel)

        return alertController
    }
}