import UIKit

public class FulfillmentContainerViewController: UIViewController {
    public var allowAnimations:Bool = true;

    public class func instantiateFromStoryboard() -> FulfillmentContainerViewController {
        return  UIStoryboard(name: "Fulfillment", bundle: nil)
            .instantiateViewControllerWithIdentifier(ViewControllerStoryboardIdentifier.FulfillmentContainer.toRaw()) as FulfillmentContainerViewController
    }
    
    @IBAction public func closeModalTapped(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(allowAnimations, completion: nil)
    }
}
