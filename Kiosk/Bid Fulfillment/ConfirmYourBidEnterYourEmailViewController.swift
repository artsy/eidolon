import UIKit

public class ConfirmYourBidEnterYourEmailViewController: UIViewController {

    public class func instantiateFromStoryboard() -> ConfirmYourBidEnterYourEmailViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBidEnterEmail) as ConfirmYourBidEnterYourEmailViewController
    }

    @IBAction public func dev_noPhoneNumberFoundTapped(sender: AnyObject) {
        self.performSegue(.SubmittedanEmailforUserDetails)
    }


    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == SegueIdentifier.SubmittedanEmailforUserDetails {
//            let confirmVC = segue.destinationViewController as ConfirmYourBidPasswordViewController
//            confirmVC.bid = Bid(id: "FAKE BID", amountCents: Int(self.bid * 100))
        }
    }


}
