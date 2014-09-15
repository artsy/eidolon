import UIKit

public class YouAreTheHighestBidderViewController: UIViewController {

    public class func instantiateFromStoryboard() -> YouAreTheHighestBidderViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.YouAreTheHighestBidder) as YouAreTheHighestBidderViewController
    }

    
}
