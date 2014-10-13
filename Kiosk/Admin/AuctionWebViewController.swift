import UIKit

class AuctionWebViewController: WebViewController {

    let exitPassword = "close"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolbarButtons = self.toolbarItems
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: "")
        
        let exitImage = UIImage(named: "toolbar_backward")?
        let backwardBarItem = UIBarButtonItem(image: exitImage, style: .Plain, target: self, action: "exit");
        let allItems = self.toolbarItems! + [flexibleSpace, backwardBarItem] as [AnyObject]
        toolbarItems = allItems
    }
    
    func exit() {
        let alertController = UIAlertController(title: "Exit Kiosk", message: nil, preferredStyle: .Alert)
        let exitAction = UIAlertAction(title: "Exit", style: .Default) { (_) in
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        
        exitAction.enabled = false
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Exit Password"

            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                // compiler crashes when using weak
                exitAction.enabled = textField.text == self.exitPassword
            }
        }
                
        alertController.addAction(exitAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {}
    }
}
