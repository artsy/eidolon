import UIKit

extension UIViewController {

    /// Short hand syntax for loading the view controller 

    func loadViewProgrammatically(){
        self.beginAppearanceTransition(true, animated: false)
        self.endAppearanceTransition()
    }

    /// Short hand syntax for performing a segue with a known hardcoded identity

    func performSegue(identifier:SegueIdentifier) {
        performSegueWithIdentifier(identifier.rawValue, sender: self)
    }

    func fulfillmentNav() -> FulfillmentNavigationController {
        return (navigationController! as FulfillmentNavigationController)
    }

    func fulfillmentContainer() -> FulfillmentContainerViewController? {
        return fulfillmentNav().parentViewController as? FulfillmentContainerViewController
    }

    func findChildViewControllerOfType(klass: AnyClass) -> UIViewController? {
        for child in childViewControllers as [UIViewController] {
            if child.isKindOfClass(klass) {
                return child
            }
        }
        return nil
    }
}
