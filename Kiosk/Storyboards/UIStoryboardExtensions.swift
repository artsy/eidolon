import UIKit

public extension UIStoryboard {

    public class func fulfillment() -> UIStoryboard {
        return UIStoryboard(name: "Fulfillment", bundle: nil)
    }

    public func viewControllerWithID(identifier:ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewControllerWithIdentifier(identifier.toRaw()) as UIViewController
    }
}
