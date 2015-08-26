import UIKit

class AuctionWebViewController: WebViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: "")
        
        let exitImage = UIImage(named: "toolbar_close")
        let backwardBarItem = UIBarButtonItem(image: exitImage, style: .Plain, target: self, action: "exit");
        let allItems = self.toolbarItems! + [flexibleSpace, backwardBarItem]
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
