import UIKit

public extension UIStoryboard {
    
    public class func auction() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.Auction.rawValue, bundle: nil)
    }

    public class func fulfillment() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.Fulfillment.rawValue, bundle: nil)
    }

    public func viewControllerWithID(identifier:ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewControllerWithIdentifier(identifier.rawValue) as! UIViewController
    }
}
