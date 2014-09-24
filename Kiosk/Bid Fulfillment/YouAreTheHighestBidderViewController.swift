import UIKit

public class YouAreTheHighestBidderViewController: UIViewController {

    public class func instantiateFromStoryboard() -> YouAreTheHighestBidderViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.YouAreTheHighestBidder) as YouAreTheHighestBidderViewController
    }
    
    @IBAction func goBackToAuction(sender: AnyObject) {
        self.navigationController?.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
