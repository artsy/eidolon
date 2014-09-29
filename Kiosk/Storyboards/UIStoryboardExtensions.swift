import UIKit

public extension UIStoryboard {

    public class func fulfillment() -> UIStoryboard {
        // TODO: Store as though lazy loading.
        return UIStoryboard(name: "Fulfillment", bundle: nil)
    }

    public func viewControllerWithID(identifier:ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewControllerWithIdentifier(identifier.rawValue) as UIViewController
    }
}
