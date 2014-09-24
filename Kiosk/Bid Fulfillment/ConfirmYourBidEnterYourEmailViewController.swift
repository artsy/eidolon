import UIKit

public class ConfirmYourBidEnterYourEmailViewController: UIViewController {

    public class func instantiateFromStoryboard() -> ConfirmYourBidEnterYourEmailViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBid) as ConfirmYourBidEnterYourEmailViewController
    }


}
