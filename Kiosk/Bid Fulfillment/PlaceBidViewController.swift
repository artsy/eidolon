import UIKit

public class PlaceBidViewController: UIViewController {

    var bid:Float = 0.0

    @IBOutlet public var bidAmountTextField: UITextField!
    @IBOutlet var keypadContainer: KeypadContainerView!

    public class func instantiateFromStoryboard() -> PlaceBidViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.PlaceYourBid) as PlaceBidViewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        keypadSignal.subscribeNext({ (input) -> Void in

            let inputFloat = Float(input as? Int ?? 0)
            self.bid = (Float(10) * self.bid) + inputFloat

            self.bidAmountTextField.text = NSNumberFormatter.currencyStringForCents(self.bid * Float(100))
        })
    }

    @IBOutlet var bidButton: Button!

    @IBAction func bidButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier(SegueIdentifier.ConfirmBid.toRaw(), sender: self)
    }

    lazy public var keypadSignal:RACSignal! = self.keypadContainer.keypad?.keypadSignal
}
