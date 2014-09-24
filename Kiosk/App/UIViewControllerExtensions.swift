import UIKit

extension UIViewController {

    /// Short hand syntax for loading the view controller 

    public func loadViewProgrammatically(){
        self.beginAppearanceTransition(true, animated: false)
        self.endAppearanceTransition()
    }

    public func performSegue(identifier:SegueIdentifier) {
        self.performSegueWithIdentifier(identifier.toRaw(), sender: self)
    }
}
