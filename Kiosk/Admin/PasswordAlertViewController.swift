
import UIKit

class PasswordAlertViewController: UIAlertController {

    class func alertView(completion: () -> ()) -> PasswordAlertViewController {
        let alertController = PasswordAlertViewController(title: "Exit Kiosk", message: nil, preferredStyle: .Alert)
        let exitAction = UIAlertAction(title: "Exit", style: .Default) { (_) in
            completion()
            return
        }

        exitAction.enabled = false
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }

        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Exit Password"

            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                // compiler crashes when using weak

                #if (arch(i386) || arch(x86_64)) && os(iOS)
                    exitAction.enabled = true
                #else
                    exitAction.enabled = textField.text == "Genome401"
                #endif
            }
        }

        alertController.addAction(exitAction)
        alertController.addAction(cancelAction)
        return alertController
    }
}
