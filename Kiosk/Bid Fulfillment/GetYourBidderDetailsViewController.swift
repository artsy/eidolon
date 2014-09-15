import UIKit

public class GetYourBidderDetailsViewController: UIViewController {

    public class func instantiateFromStoryboard() -> GetYourBidderDetailsViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.GetYourBidderDetails) as GetYourBidderDetailsViewController
    }

}
