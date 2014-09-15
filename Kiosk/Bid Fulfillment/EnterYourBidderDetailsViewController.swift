import UIKit

public class EnterYourBidderDetailsViewController: UIViewController {

    public class func instantiateFromStoryboard() -> EnterYourBidderDetailsViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.EnterYourBidDetails) as EnterYourBidderDetailsViewController
    }

}
