class KioskTests {

}

import UIKit

public extension UIStoryboard {

    public class func fulfillment() -> UIStoryboard {
        // This will ensure that a storyboard instance comes out of the testing bundle
        // instead of the MainBundle.

        return UIStoryboard(name: "Fulfillment", bundle: NSBundle(forClass: KioskTests.self))
    }

    public func viewControllerWithID(identifier:ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewControllerWithIdentifier(identifier.toRaw()) as UIViewController
    }
}
