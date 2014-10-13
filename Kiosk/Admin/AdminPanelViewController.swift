import UIKit

class AdminPanelViewController: UIViewController {

    @IBAction func backTapped(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeAppTapped(sender: AnyObject) {
        exit(1)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .LoadAdminWebViewController {
            let webVC = segue.destinationViewController as WebViewController
            webVC.URL = NSURL(string: "https://staging.artsy.net/feature/ici-live-auction")!
        }
    }
}
