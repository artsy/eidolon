import UIKit

public class PlaceBidViewController: UIViewController {

    public class func instantiateFromStoryboard() -> PlaceBidViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.PlaceYourBid) as PlaceBidViewController
    }


    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet var bidButton: Button!

    @IBAction func bidButtonTapped(sender: AnyObject) {

        self.performSegueWithIdentifier(SegueIdentifier.ConfirmBid.toRaw(), sender: self)

    }
}
