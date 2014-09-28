import UIKit

public class PlaceBidViewController: UIViewController {

    dynamic var bid: Float = 0.0

    @IBOutlet public var bidAmountTextField: UITextField!
    @IBOutlet var keypadContainer: KeypadContainerView!

    @IBOutlet var currentBidLabel: UILabel!
    @IBOutlet var nextBidAmountLabel: UILabel!

    var saleArtwork: SaleArtwork?

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

        keypadSignal.subscribeNext({ [weak self] (input) -> Void in
            let inputFloat = input as? Float ?? 0.0
            self?.bid = (10.0 * self!.bid) + inputFloat
        })

        if let saleArtwork:SaleArtwork = self.saleArtwork {
            RAC(currentBidLabel, "text") <~ RACObserve(saleArtwork, "openingBidCents").map({ "$\($0)" })
            RAC(nextBidAmountLabel, "text") <~ RACObserve(saleArtwork, "openingBidCents").map({ "Enter \($0) or more" })
        }
    }

    @IBOutlet public var bidButton: UIButton!
    @IBAction func bidButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier(SegueIdentifier.ConfirmBid.toRaw(), sender: self)
    }

    lazy public var keypadSignal:RACSignal! = self.keypadContainer.keypad?.keypadSignal
}
