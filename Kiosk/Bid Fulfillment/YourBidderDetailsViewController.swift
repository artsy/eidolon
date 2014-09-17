import UIKit

public class YourBidderDetailsViewController: UIViewController {

    public class func instantiateFromStoryboard() -> YourBidderDetailsViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.YourBidderDetails) as YourBidderDetailsViewController
    }

}
