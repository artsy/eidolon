import UIKit

class AdminPanelViewController: UIViewController {

    @IBOutlet weak var serverSwitch: UISwitch!
    @IBOutlet weak var auctionIDLabel: UILabel!


    @IBAction func backTapped(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeAppTapped(sender: AnyObject) {
        exit(1)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: Show help button
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .LoadAdminWebViewController {
            let webVC = segue.destinationViewController as WebViewController
            let auctionID = AppSetup.sharedState.auctionID
            let base = AppSetup.sharedState.useStaging ? "staging.artsy.net" : "artsy.net"

            webVC.URL = NSURL(string: "https://\(base)/feature/\(auctionID)")!
            webVC.showToolbar = true

            // TODO: Hide help button
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        auctionIDLabel.text = AppSetup.sharedState.auctionID
        let environment = AppSetup.sharedState.useStaging ? "PRODUCTION" : "STAGING"
        environmentChangeButton.setTitle("USE \(environment)", forState: .Normal)
    }

    @IBOutlet weak var environmentChangeButton: ActionButton!
    @IBAction func switchStagingProductionTapped(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(!AppSetup.sharedState.useStaging, forKey: "KioskUseStaging")
        defaults.synchronize()
        exit(1)
    }

}
