import UIKit

public extension UIStoryboard {

    public class func fulfillment() -> UIStoryboard {
        // TODO: Store as though lazy loading.
        return UIStoryboard(name: "Fulfillment", bundle: nil)
    }

    public func viewControllerWithID(identifier:ViewControllerStoryboardIdentifier) -> AnyObject {
        return self.instantiateViewControllerWithIdentifier(identifier.toRaw()) as AnyObject
    }
}
