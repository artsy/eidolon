class KioskTests {}

import ObjectiveC
import UIKit
import Kiosk

var sharedInstances = Dictionary<String, AnyObject>()

extension UIStoryboard {
    
    class func auction() -> UIStoryboard {
        // This will ensure that a storyboard instance comes out of the testing bundle
        // instead of the MainBundle.

        return UIStoryboard(name: "Auction", bundle: NSBundle(forClass: KioskTests.self))
    }
    
    class func fulfillment() -> UIStoryboard {
        // This will ensure that a storyboard instance comes out of the testing bundle
        // instead of the MainBundle.

        return UIStoryboard(name: "Fulfillment", bundle: NSBundle(forClass: KioskTests.self))
    }

    func viewControllerWithID(identifier: ViewControllerStoryboardIdentifier) -> UIViewController {
        let id = identifier.rawValue

        // Uncomment for experimental caching.
//
//        if let cached: NSData = sharedInstances[id] as NSData {
//            return NSKeyedUnarchiver.unarchiveObjectWithData(cached) as UIViewController
//
//        } else {
            let vc = self.instantiateViewControllerWithIdentifier(id) as UIViewController
//            sharedInstances[id] = NSKeyedArchiver.archivedDataWithRootObject(vc);
            vc.wrapInFulfillmentNav()
            return vc;
//        }

    }
}

var AssociatedObjectHandle: UInt8 = 0

extension UIViewController {
    func wrapInFulfillmentNav() {
        let nav = FulfillmentNavigationController(rootViewController: self)
        nav.auctionID = ""
        objc_setAssociatedObject(self, &AssociatedObjectHandle, nav, UInt(OBJC_ASSOCIATION_RETAIN))
    }
}
