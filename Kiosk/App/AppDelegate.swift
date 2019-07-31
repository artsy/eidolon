import UIKit
import ARAnalytics
import SDWebImage
import RxSwift
import Keys
import Stripe
import MediaPlayer

typealias EidolonKeys = KioskKeys

let PhoneNumberRegionKey = "PhoneNumberRegion"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let helpViewController = Variable<HelpViewController?>(nil)
    var helpButton: UIButton!

    weak var webViewController: UIViewController?

    var window: UIWindow? = UIWindow(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width))

    fileprivate(set) var provider = Networking.newDefaultNetworking()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Disable sleep timer
        UIApplication.shared.isIdleTimerDisabled = true

        // Set up network layer
        if StubResponses.stubResponses() {
            provider = Networking.newStubbingNetworking()
        }


        // I couldn't figure how to swizzle this out like we do in objc.
        if let _ = NSClassFromString("XCTest") { return true }

        // Clear possible old contents from cache and defaults. 
        let imageCache = SDImageCache.shared()
        imageCache?.clearDisk()

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: XAppToken.DefaultsKeys.TokenKey.rawValue)
        defaults.removeObject(forKey: XAppToken.DefaultsKeys.TokenExpiry.rawValue)

        defaults.register(defaults: [PhoneNumberRegionKey: "US"])

        let auctionStoryboard = UIStoryboard.auction()
        let appViewController = auctionStoryboard.instantiateInitialViewController() as? AppViewController
        appViewController?.provider = provider
        window?.rootViewController = appViewController
        window?.makeKeyAndVisible()

        let keys = EidolonKeys()

        if AppSetup.sharedState.useStaging {
            Stripe.setDefaultPublishableKey(keys.stripeStagingPublishableKey)
        } else {
            Stripe.setDefaultPublishableKey(keys.stripeProductionPublishableKey)
        }

        ARAnalytics.setup(withAnalytics: [
            ARHockeyAppBetaID: keys.hockeyBetaSecret,
            ARHockeyAppLiveID: keys.hockeyProductionSecret,
            ARSegmentioWriteKey: keys.segmentWriteKey
        ])

        setupHelpButton()
        setupUserAgent()

        logger.log("App Started")
        ARAnalytics.event("Session Started")

        // CardFlight v3 has a problem displaying the volume HUD (from a background thread, I think it confuses iOS).
        // However, we can't upgrade to v4 yet. See for more info: https://artsyproduct.atlassian.net/browse/PURCHASE-615
        let volumeView = MPVolumeView(frame: .zero)
        volumeView.clipsToBounds = true
        window?.addSubview(volumeView)

        return true
    }

    func setupUserAgent() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String?
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String?
        
        let webView = UIWebView(frame: CGRect.zero)
        let oldAgent = webView.stringByEvaluatingJavaScript(from: "navigator.userAgent")
        
        let agentString = "\(String(describing: oldAgent)) Artsy-Mobile/\(version!) Eigen/\(build!) Kiosk Eidolon"

        let defaults = UserDefaults.standard
        let userAgentDict = ["UserAgent": agentString]
        defaults.register(defaults: userAgentDict)
    }
}

