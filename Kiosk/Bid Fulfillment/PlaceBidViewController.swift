import UIKit

class PlaceBidViewController: UIViewController {

    dynamic var bid: Float = 0.0

    @IBOutlet var bidAmountTextField: UITextField!
    @IBOutlet var keypadContainer: KeypadContainerView!

    @IBOutlet var currentBidLabel: UILabel!
    @IBOutlet var nextBidAmountLabel: UILabel!

    @IBOutlet var artistNameLabel: ARSerifLabel!
    @IBOutlet var artworkTitleLabel: ARSerifLabel!
    @IBOutlet var artworkPriceLabel: ARSerifLabel!

    var saleArtwork: SaleArtwork?

    class func instantiateFromStoryboard() -> PlaceBidViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.PlaceYourBid) as PlaceBidViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let keypad = self.keypadContainer!.keypad!
        let bidIsZeroSignal = RACObserve(self, "bid").map { return ($0 as Float == 0) }

        for button in [bidButton, keypad.rightButton, keypad.leftButton] {
            RAC(button, "enabled") <~ bidIsZeroSignal.notEach()
        }

        let formattedBidTextSignal = RACObserve(self, "bid").map({ (bid) -> AnyObject! in
            return NSNumberFormatter.currencyStringForCents(bid as Float * 100.0)
        })

        RAC(bidAmountTextField, "text") <~ RACSignal.`if`(bidIsZeroSignal, then: RACSignal.defer{ RACSignal.`return`("") }, `else`: formattedBidTextSignal)

        keypadSignal.subscribeNext(addDigitToBid)
        deleteSignal.subscribeNext(deleteBid)
        clearSignal.subscribeNext(clearBid)

        if let saleArtwork:SaleArtwork = self.saleArtwork {
            RAC(currentBidLabel, "text") <~ RACObserve(saleArtwork, "openingBidCents").map(toCurrentBidString)
            RAC(nextBidAmountLabel, "text") <~ RACObserve(saleArtwork, "openingBidCents").map(toOpeningBidString)

            if let artist = saleArtwork.artwork.artists?.first {
                RAC(artistNameLabel, "text") <~ RACObserve(artist, "name")
            }
            RAC(artworkTitleLabel, "text") <~ RACObserve(saleArtwork.artwork, "title")
            RAC(artworkPriceLabel, "text") <~ RACObserve(saleArtwork.artwork, "price")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == SegueIdentifier.ConfirmBid {
            let confirmVC = segue.destinationViewController as ConfirmYourBidViewController
            confirmVC.bid = Bid(id: "FAKE BID", amountCents: Int(self.bid * 100))
        }
    }

    @IBOutlet var bidButton: UIButton!
    @IBAction func bidButtonTapped(sender: AnyObject) {
        self.performSegue(SegueIdentifier.ConfirmBid)
    }

    lazy var keypadSignal:RACSignal! = self.keypadContainer.keypad?.keypadSignal
    lazy var clearSignal:RACSignal!  = self.keypadContainer.keypad?.rightSignal
    lazy var deleteSignal:RACSignal! = self.keypadContainer.keypad?.leftSignal
}

/// These are for RAC only

private extension PlaceBidViewController {

    func addDigitToBid(input:AnyObject!) -> Void {
        let inputFloat = input as? Float ?? 0.0
        self.bid = (10.0 * self.bid) + inputFloat
    }

    func deleteBid(cents:AnyObject!) -> Void {
        self.bid /= 10
    }

    func clearBid(cents:AnyObject!) -> Void {
        self.bid = 10
    }

    func toCurrentBidString(cents:AnyObject!) -> AnyObject! {
        if let dollars = NSNumberFormatter.currencyStringForCents(cents as? Int) {
            return dollars
        }
        return ""
    }

    func toOpeningBidString(cents:AnyObject!) -> AnyObject! {
        if let dollars = NSNumberFormatter.currencyStringForCents(cents as? Int) {
            return "Enter \(dollars) or more"
        }
        return ""
    }
}
