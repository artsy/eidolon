import UIKit

public class UserCreationViewController: UIViewController {

    public class func instantiateFromStoryboard() -> UserCreationViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.UserCreation) as UserCreationViewController
    }

}
