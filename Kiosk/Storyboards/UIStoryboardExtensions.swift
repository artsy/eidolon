import UIKit

extension UIStoryboard {
    
    class func auction() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.Auction.rawValue, bundle: nil)
    }

    class func fulfillment() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.Fulfillment.rawValue, bundle: nil)
    }

    func viewController(withID identifier:ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewController(withIdentifier: identifier.rawValue)
    }
}
