import UIKit

public extension UIStoryboard {
    
    class func auction() -> UIStoryboard {
        return UIStoryboard(name: "Auction", bundle:nil)
    }

    public class func fulfillment() -> UIStoryboard {
        return UIStoryboard(name: "Fulfillment", bundle: nil)
    }

    public func viewControllerWithID(identifier:ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewControllerWithIdentifier(identifier.rawValue) as UIViewController
    }
}
