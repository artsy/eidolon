import UIKit
import ARAnalytics
import SDWebImage
import RxSwift
import Keys
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let helpViewController = Variable<HelpViewController?>(nil)
    var helpButton: UIButton!

    weak var webViewController: UIViewController?

    var window: UIWindow? = UIWindow(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width))

    private(set) var provider = Networking.newDefaultNetworking()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        // Disable sleep timer
        UIApplication.sharedApplication().idleTimerDisabled = true

        // Set up network layer
        if StubResponses.stubResponses() {
            provider = Networking.newStubbingNetworking()
        }


        // I couldn't figure how to swizzle this out like we do in objc.
        if let _ = NSClassFromString("XCTest") { return true }

        // Clear possible old contents from cache and defaults. 
        let imageCache = SDImageCache.sharedImageCache()
        imageCache.clearDisk()

        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(XAppToken.DefaultsKeys.TokenKey.rawValue)
        defaults.removeObjectForKey(XAppToken.DefaultsKeys.TokenExpiry.rawValue)

        let auctionStoryboard = UIStoryboard.auction()
        let appViewController = auctionStoryboard.instantiateInitialViewController() as? AppViewController
        appViewController?.provider = provider
        window?.rootViewController = appViewController
        window?.makeKeyAndVisible()

        let keys = EidolonKeys()

        if AppSetup.sharedState.useStaging {
            Stripe.setDefaultPublishableKey(keys.stripeStagingPublishableKey())
        } else {
            Stripe.setDefaultPublishableKey(keys.stripeProductionPublishableKey())
        }

        let mixpanelToken = AppSetup.sharedState.useStaging ? keys.mixpanelStagingAPIClientKey() : keys.mixpanelProductionAPIClientKey()

        ARAnalytics.setupWithAnalytics([
            ARHockeyAppBetaID: keys.hockeyBetaSecret(),
            ARHockeyAppLiveID: keys.hockeyProductionSecret(),
            ARMixpanelToken: mixpanelToken
        ])

        setupHelpButton()
        setupUserAgent()

        logger.log("App Started")
        ARAnalytics.event("Session Started")
        return true
    }

    func setupUserAgent() {
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String?
        let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as! String?
        
        let webView = UIWebView(frame: CGRectZero)
        let oldAgent = webView.stringByEvaluatingJavaScriptFromString("navigator.userAgent")
        
        let agentString = "\(oldAgent) Artsy-Mobile/\(version!) Eigen/\(build!) Kiosk Eidolon"

        let defaults = NSUserDefaults.standardUserDefaults()
        let userAgentDict = ["UserAgent": agentString]
        defaults.registerDefaults(userAgentDict)
    }
}

