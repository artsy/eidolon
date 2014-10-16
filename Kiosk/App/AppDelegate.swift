import UIKit

let AuctionID = "ici-live-auction"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var helpViewController: HelpViewController?
    var helpButton: UIButton!
                            
    var window: UIWindow! = UIWindow(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width))

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {

//        Provider.sharedProvider = Provider.StubbingProvider()

        // I couldn't figure how to swizzle this out like we do in objc.
        if let inTests: AnyClass = NSClassFromString("XCTest") { return true}

        let auctionStoryboard = UIStoryboard(name: "Auction", bundle: nil)

        window.rootViewController = auctionStoryboard.instantiateInitialViewController() as? UIViewController
        window.makeKeyAndVisible()

        let keys = EidolonKeys()
        ARAnalytics.setupWithAnalytics([
            ARHockeyAppBetaID: keys.hockeyBetaSecret(),
            ARHockeyAppLiveID: keys.hockeyProductionSecret(),
            ARMixpanelToken: keys.mixpanelProductionAPIClientKey()
        ])
        
        setupHelpButton()
        setupUserAgent()

        return true
    }

    func setupUserAgent() {
        
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as String?
        let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as String?
        
        let webView = UIWebView(frame: CGRectZero)
        let oldAgent = webView.stringByEvaluatingJavaScriptFromString("navigator.userAgent")
        
        let agentString = "\(oldAgent) Artsy-Mobile/\(version!) Eigen/\(build!) Kiosk Eidolon"

        let defaults = NSUserDefaults.standardUserDefaults()
        let userAgentDict = ["UserAgent" as NSObject : agentString]
        defaults.registerDefaults(userAgentDict)
    }
}

