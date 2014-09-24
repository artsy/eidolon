import UIKit

public class SwipeCreditCardViewController: UIViewController {

    public class func instantiateFromStoryboard() -> SwipeCreditCardViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.SwipeCreditCard) as SwipeCreditCardViewController
    }

    @IBAction public func dev_CardRegisteredTapped(sender: AnyObject) {
        self.performSegue(.CardRegistered)
    }

}
