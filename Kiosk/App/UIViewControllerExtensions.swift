import UIKit

public extension UIViewController {

    /// Short hand syntax for loading the view controller 

    public func loadViewProgrammatically(){
        self.beginAppearanceTransition(true, animated: false)
        self.endAppearanceTransition()
    }

    /// Short hand syntax for performing a segue with a known hardcoded identity

    public func performSegue(identifier:SegueIdentifier) {
        performSegueWithIdentifier(identifier.rawValue, sender: self)
    }

    public func fulfillmentNav() -> FulfillmentNavigationController {
        return (navigationController! as! FulfillmentNavigationController)
    }

    public func fulfillmentContainer() -> FulfillmentContainerViewController? {
        return fulfillmentNav().parentViewController as? FulfillmentContainerViewController
    }

    public func findChildViewControllerOfType(klass: AnyClass) -> UIViewController? {
        for child in childViewControllers {
            if child.isKindOfClass(klass) {
                return child
            }
        }
        return nil
    }
}
