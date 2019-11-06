import UIKit
import Artsy_UILabels

class AdminPanelViewController: UIViewController {

    @IBOutlet weak var auctionIDLabel: UILabel!


    @IBAction func backTapped(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        appDelegate().setHelpButtonHidden(false)
    }

    @IBAction func closeAppTapped(_ sender: AnyObject) {
        exit(1)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        appDelegate().setHelpButtonHidden(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue == .LoadAdminWebViewController {
            let webVC = segue.destination as! AuctionWebViewController
            let auctionID = AppSetup.sharedState.auctionID
            let base = AppSetup.sharedState.useStaging ? "staging.artsy.net" : "artsy.net"

            webVC.url = URL(string: "https://\(base)/feature/\(auctionID)")!

            // TODO: Hide help button
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let state = AppSetup.sharedState

        if APIKeys.sharedKeys.stubResponses {
            auctionIDLabel.text = "STUBBING API RESPONSES\nNOT CONTACTING ARTSY API"
        } else {
            let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)  ?? "Unknown"
            auctionIDLabel.text = "\(state.auctionID), Kiosk version: \(version)"
        }

        let environment = state.useStaging ? "PRODUCTION" : "STAGING"
        environmentChangeButton.setTitle("USE \(environment)", for: .normal)

        let buttonsTitle = state.showDebugButtons ? "HIDE" : "SHOW"
        showAdminButtonsButton.setTitle(buttonsTitle, for: .normal)

        phoneNumberRegionButton.setTitle(UserDefaults.standard.string(forKey: PhoneNumberRegionKey), for: .normal)
    }

    @IBOutlet weak var phoneNumberRegionButton: UIButton!
    @IBAction func phoneNumberRegionButtonPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        let setRegion = { [weak self] (region: String) in
            defaults.set(region, forKey: PhoneNumberRegionKey)
            self?.phoneNumberRegionButton.setTitle(region, for: .normal)
        }

        let alertController = UIAlertController(title: "Phone Number Region", message: "This affects user registration. We format phone numbers based on a default region, select the region the Kiosk is in below.", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Two-letter region code"
        }
        alertController.addAction(UIAlertAction(title: "United States (US)", style: .default, handler: { _ in
            setRegion("US")
        }))
        alertController.addAction(UIAlertAction(title: "United Kingdon (GB)", style: .default, handler: { _ in
            setRegion("GB")
        }))
        alertController.addAction(UIAlertAction(title: "Use custom string", style: .destructive, handler: { action in
            let text = (alertController.textFields?.first)?.text ?? "US" // fall back to the US if it's empty
            setRegion(text)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)
    }


    @IBOutlet weak var environmentChangeButton: UIButton!
    @IBAction func switchStagingProductionTapped(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        defaults.set(!AppSetup.sharedState.useStaging, forKey: "KioskUseStaging")

        defaults.removeObject(forKey: XAppToken.DefaultsKeys.TokenKey.rawValue)
        defaults.removeObject(forKey: XAppToken.DefaultsKeys.TokenExpiry.rawValue)

        defaults.synchronize()
        delayToMainThread(1){
            exit(1)
        }

    }

    @IBOutlet weak var showAdminButtonsButton: UIButton!
    @IBAction func toggleAdminButtons(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        defaults.set(!AppSetup.sharedState.showDebugButtons, forKey: "KioskShowDebugButtons")
        defaults.synchronize()
        delayToMainThread(1){
            exit(1)
        }

    }
}
