import UIKit

public class FulfillmentContainerViewController: UIViewController {
    var allowAnimations:Bool = true;

    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet var backgroundView: UIView!

    override public func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext

        contentView.alpha = 0
        backgroundView.alpha = 0
        cancelButton.alpha = 0
    }

    // We force viewDidAppear to access the PlaceBidViewController
    // so this allow animations in the modal

    // This is mostly a placeholder for a more complex animation in the future

    func viewDidAppearAnimation(animated: Bool) {
        self.contentView.frame = CGRectOffset(self.contentView.frame, 0, 100)
        UIView.animateTwoStepIf(animated, withDuration: 0.3, { () -> Void in
            self.backgroundView.alpha = 1

        }, midway: { () -> Void in
            self.contentView.alpha = 1
            self.cancelButton.alpha = 1
            self.contentView.frame = CGRectOffset(self.contentView.frame, 0, -100)
        }) { (complete) -> Void in

        }
    }

    @IBAction func closeModalTapped(sender: AnyObject) {
        closeFulfillmentModal()
    }

    func closeFulfillmentModal(completion: (() -> ())? = nil) -> Void {
        UIView.animateIf(allowAnimations, withDuration: 0.4, { () -> Void in
            self.contentView.alpha = 0
            self.backgroundView.alpha = 0
            self.cancelButton.alpha = 0

            }) { (completed:Bool) -> Void in
                let presentingVC = self.presentingViewController!
                presentingVC.dismissViewControllerAnimated(false, completion: nil)
                completion?()
        }
    }

    func internalNavigationController() -> FulfillmentNavigationController? {

        self.loadViewProgrammatically()
        return self.childViewControllers.first as? FulfillmentNavigationController
    }

    class func instantiateFromStoryboard() -> FulfillmentContainerViewController {
        return  UIStoryboard(name: "Fulfillment", bundle: nil)
            .instantiateViewControllerWithIdentifier(ViewControllerStoryboardIdentifier.FulfillmentContainer.rawValue) as FulfillmentContainerViewController
    }
    
}
