import UIKit

extension UIViewController {

    /// Short hand syntax for loading the view controller 

    func loadViewProgrammatically(){
        self.beginAppearanceTransition(true, animated: false)
        self.endAppearanceTransition()
    }

    /// Short hand syntax for performing a segue with a known hardcoded identity

    func performSegue(identifier:SegueIdentifier) {
        self.performSegueWithIdentifier(identifier.rawValue, sender: self)
    }

    func fulfilmentNav() -> FulfillmentNavigationController? {

        return (self.navigationController as? FulfillmentNavigationController)?
    }
}
