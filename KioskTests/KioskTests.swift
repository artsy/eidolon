class KioskTests {}

import UIKit

var sharedInstances = Dictionary<String, AnyObject>()

public extension UIStoryboard {

    public class func fulfillment() -> UIStoryboard {
        // This will ensure that a storyboard instance comes out of the testing bundle
        // instead of the MainBundle.

        return UIStoryboard(name: "Fulfillment", bundle: NSBundle(forClass: KioskTests.self))
    }

    public func viewControllerWithID(identifier:ViewControllerStoryboardIdentifier) -> UIViewController {
        let id = identifier.rawValue

        // Uncomment for experimental caching.
//
//        if let cached: NSData = sharedInstances[id] as NSData {
//            return NSKeyedUnarchiver.unarchiveObjectWithData(cached) as UIViewController
//
//        } else {
            let vc = self.instantiateViewControllerWithIdentifier(id) as UIViewController
//            sharedInstances[id] = NSKeyedArchiver.archivedDataWithRootObject(vc);
            return vc;
//        }

    }
}
