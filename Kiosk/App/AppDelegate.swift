import UIKit
import ARAnalytics
import XCGLogger
import SDWebImage

let logger = XCGLogger.defaultInstance()

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {
    
    weak var helpViewController: HelpViewController?
    var helpButton: UIButton!

    weak var webViewController: UIViewController?

    var window: UIWindow! = UIWindow(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width))

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {

//        Provider.sharedProvider = Provider.StubbingProvider()

        // I couldn't figure how to swizzle this out like we do in objc.
        if let inTests: AnyClass = NSClassFromString("XCTest") { return true }

        // Clear possible old contents from cache and deafults. 
        let imageCache = SDImageCache.sharedImageCache()
        imageCache.clearDisk()

        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(XAppToken.DefaultsKeys.TokenKey.rawValue)
        defaults.removeObjectForKey(XAppToken.DefaultsKeys.TokenExpiry.rawValue)

        let auctionStoryboard = UIStoryboard(name: "Auction", bundle: nil)
        window.rootViewController = auctionStoryboard.instantiateInitialViewController() as? UIViewController
        window.makeKeyAndVisible()

        let keys = EidolonKeys()
        let mixpanelToken = AppSetup.sharedState.useStaging ? keys.mixpanelStagingAPIClientKey() : keys.mixpanelProductionAPIClientKey()

        ARAnalytics.setupWithAnalytics([
            ARHockeyAppBetaID: keys.hockeyBetaSecret(),
            ARHockeyAppLiveID: keys.hockeyProductionSecret(),
            ARMixpanelToken: mixpanelToken
        ])

        setupHelpButton()
        setupUserAgent()

        let destination = XCGFileLogDestination(owner: logger, writeToFile: logPath(), identifier: "main")
        logger.addLogDestination(destination)

        logger.debug("App Started")
        ARAnalytics.event("Session Started")
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

    func logPath() -> NSURL {
        let docs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as NSURL
        return docs.URLByAppendingPathComponent("logger.txt")
    }
}

