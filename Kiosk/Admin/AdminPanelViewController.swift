import UIKit
import Artsy_UILabels

class AdminPanelViewController: UIViewController {

    @IBOutlet weak var auctionIDLabel: UILabel!


    @IBAction func backTapped(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        appDelegate().setHelpButtonHidden(false)
    }

    @IBAction func closeAppTapped(sender: AnyObject) {
        exit(1)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        appDelegate().setHelpButtonHidden(true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .LoadAdminWebViewController {
            let webVC = segue.destinationViewController as! AuctionWebViewController
            let auctionID = AppSetup.sharedState.auctionID
            let base = AppSetup.sharedState.useStaging ? "staging.artsy.net" : "artsy.net"

            webVC.URL = NSURL(string: "https://\(base)/feature/\(auctionID)")!

            // TODO: Hide help button
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let state = AppSetup.sharedState

        if APIKeys.sharedKeys.stubResponses {
            auctionIDLabel.text = "STUBBING API RESPONSES\nNOT CONTACTING ARTSY API"
        } else {
            let version = (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String)  ?? "Unknown"
            auctionIDLabel.text = "\(state.auctionID), Kiosk version: \(version)"
        }

        let environment = state.useStaging ? "PRODUCTION" : "STAGING"
        environmentChangeButton.setTitle("USE \(environment)", forState: .Normal)

        let buttonsTitle = state.showDebugButtons ? "HIDE" : "SHOW"
        showAdminButtonsButton.setTitle(buttonsTitle, forState: .Normal)

        let readStatus = state.disableCardReader ? "ENABLE" : "DISABLE"
        toggleCardReaderButton.setTitle(readStatus, forState: .Normal)
    }

    @IBOutlet weak var environmentChangeButton: UIButton!
    @IBAction func switchStagingProductionTapped(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(!AppSetup.sharedState.useStaging, forKey: "KioskUseStaging")

        defaults.removeObjectForKey(XAppToken.DefaultsKeys.TokenKey.rawValue)
        defaults.removeObjectForKey(XAppToken.DefaultsKeys.TokenExpiry.rawValue)

        defaults.synchronize()
        delayToMainThread(1){
            exit(1)
        }

    }

    @IBOutlet weak var showAdminButtonsButton: UIButton!
    @IBAction func toggleAdminButtons(sender: UIButton) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(!AppSetup.sharedState.showDebugButtons, forKey: "KioskShowDebugButtons")
        defaults.synchronize()
        delayToMainThread(1){
            exit(1)
        }

    }

    @IBOutlet weak var cardReaderLabel: ARSerifLabel!
    @IBOutlet weak var toggleCardReaderButton: SecondaryActionButton!
    @IBAction func toggleCardReaderTapped(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(!AppSetup.sharedState.disableCardReader, forKey: "KioskDisableCardReader")
        defaults.synchronize()
        delayToMainThread(1){
            exit(1)
        }
    }
}
