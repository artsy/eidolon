import UIKit

class AdminPanelViewController: UIViewController {

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
            let webVC = segue.destinationViewController as AuctionWebViewController
            let auctionID = AppSetup.sharedState.auctionID
            let base = AppSetup.sharedState.useStaging ? "staging.artsy.net" : "artsy.net"

            webVC.URL = NSURL(string: "https://\(base)/feature/\(auctionID)")!

            // TODO: Hide help button
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let state = AppSetup.sharedState

        auctionIDLabel.text = state.auctionID

        let environment = state.useStaging ? "PRODUCTION" : "STAGING"
        environmentChangeButton.setTitle("USE \(environment)", forState: .Normal)

        let buttonsTitle = state.showDebugButtons ? "HIDE" : "SHOW"
        showAdminButtonsButton.setTitle(buttonsTitle, forState: .Normal)
    }

    @IBOutlet weak var environmentChangeButton: ActionButton!
    @IBAction func switchStagingProductionTapped(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(!AppSetup.sharedState.useStaging, forKey: "KioskUseStaging")
        defaults.synchronize()
        exit(1)
    }

    @IBOutlet weak var showAdminButtonsButton: ActionButton!
    @IBAction func toggleAdminButtons(sender: ActionButton) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(!AppSetup.sharedState.showDebugButtons, forKey: "KioskShowDebugButtons")
        defaults.synchronize()
        exit(1)
    }
}
