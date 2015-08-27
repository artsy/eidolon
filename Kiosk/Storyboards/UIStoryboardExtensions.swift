import UIKit

extension UIStoryboard {
    
    class func auction() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.Auction.rawValue, bundle: nil)
    }

    class func fulfillment() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.Fulfillment.rawValue, bundle: nil)
    }

    func viewControllerWithID(identifier:ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewControllerWithIdentifier(identifier.rawValue)
    }
}
