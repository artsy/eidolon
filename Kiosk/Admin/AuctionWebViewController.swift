import UIKit

class AuctionWebViewController: WebViewController {

    let exitPassword = "Genome401"
    
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
        let passwordVC = PasswordAlertViewController.alertView { [weak self] () -> () in
            self?.navigationController?.popViewControllerAnimated(true)
            return
        }
        self.presentViewController(passwordVC, animated: true) {}
    }
}
