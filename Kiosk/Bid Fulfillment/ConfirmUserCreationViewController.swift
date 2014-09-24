import UIKit

public class ConfirmUserCreationViewController: UIViewController {

    public class func instantiateFromStoryboard() -> ConfirmUserCreationViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmUserCreation) as ConfirmUserCreationViewController
    }

    @IBAction func confirmButtonTapped(sender: AnyObject) {
        self.performSegue(.UserCreationorUpdatingFinished)
    }

}
