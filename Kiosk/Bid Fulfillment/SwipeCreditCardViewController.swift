import UIKit

public class SwipeCreditCardViewController: UIViewController {

    public class func instantiateFromStoryboard() -> SwipeCreditCardViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.SwipeCreditCard) as SwipeCreditCardViewController
    }

    public override func viewDidAppear(animated: Bool) {
        let after = dispatch_time(DISPATCH_TIME_NOW, 100000000)
        dispatch_after(after , dispatch_get_main_queue()) {
            self.performSegueWithIdentifier(SegueIdentifier.CardRegistered.toRaw(), sender: self);
        }
    }
}
