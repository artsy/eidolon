import UIKit

class FulfillmentContainerViewController: UIViewController {
    var allowAnimations:Bool = true;

    func placeBidViewController() -> PlaceBidViewController? {

        self.loadViewProgrammatically()
        let internalNavigationController = self.childViewControllers.first as UINavigationController
        return internalNavigationController.childViewControllers.first as? PlaceBidViewController
    }

    class func instantiateFromStoryboard() -> FulfillmentContainerViewController {
        return  UIStoryboard(name: "Fulfillment", bundle: nil)
            .instantiateViewControllerWithIdentifier(ViewControllerStoryboardIdentifier.FulfillmentContainer.toRaw()) as FulfillmentContainerViewController
    }
    
    @IBAction func closeModalTapped(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(allowAnimations, completion: nil)
    }
}
