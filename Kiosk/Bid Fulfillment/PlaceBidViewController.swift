import UIKit

public class PlaceBidViewController: UIViewController {

    dynamic var bid: Float = 0.0

    @IBOutlet public var bidAmountTextField: UITextField!
    @IBOutlet var keypadContainer: KeypadContainerView!

    public class func instantiateFromStoryboard() -> PlaceBidViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.PlaceYourBid) as PlaceBidViewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bidIsZeroSignal = RACObserve(self, "bid").map({ (bid) -> AnyObject! in
            return (bid as Float == 0)
        })
        let formattedBidTextSignal = RACObserve(self, "bid").map({ (bid) -> AnyObject! in
            return NSNumberFormatter.currencyStringForCents(bid as Float * 100.0)
        })
        
        RAC(bidButton, "enabled") <~ bidIsZeroSignal.notEach()
        RAC(bidAmountTextField, "text") <~ RACSignal.`if`(bidIsZeroSignal, then: RACSignal.`return`(""), `else`: formattedBidTextSignal)

        keypadSignal.subscribeNext({ (input) -> Void in
            let inputFloat = input as? Float ?? 0.0
            self.bid = (10.0 * self.bid) + inputFloat
        })
    }

    @IBOutlet public var bidButton: UIButton!
    @IBAction func bidButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier(SegueIdentifier.ConfirmBid.toRaw(), sender: self)
    }

    lazy public var keypadSignal:RACSignal! = self.keypadContainer.keypad?.keypadSignal
}
