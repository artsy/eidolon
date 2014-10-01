import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow! = UIWindow(frame:UIScreen.mainScreen().bounds)

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {

//        Provider.sharedProvider = Provider.StubbingProvider()
        // I couldn't figure how to swizzle this out like we do in objc.

        if let inTests: AnyClass = NSClassFromString("XCTest") { return true}

        let auctionStoryboard = UIStoryboard(name: "Auction", bundle: nil)
        let rootVC = auctionStoryboard.instantiateInitialViewController() as UINavigationController

        window.rootViewController = rootVC
        window.makeKeyAndVisible()

        return true
    }

}

