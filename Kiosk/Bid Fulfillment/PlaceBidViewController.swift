import UIKit
import Artsy_UILabels

class PlaceBidViewController: UIViewController {

    dynamic var bidDollars: Int = 0
    var hasAlreadyPlacedABid: Bool = false

    @IBOutlet var bidAmountTextField: TextField!
    @IBOutlet var cursor: CursorView!
    @IBOutlet var keypadContainer: KeypadContainerView!

    @IBOutlet var currentBidTitleLabel: UILabel!
    @IBOutlet var currentBidAmountLabel: UILabel!
    @IBOutlet var nextBidAmountLabel: UILabel!

    @IBOutlet var artworkImageView: UIImageView!
    @IBOutlet var artistNameLabel: ARSerifLabel!
    @IBOutlet var artworkTitleLabel: ARSerifLabel!
    @IBOutlet var artworkPriceLabel: ARSerifLabel!

    lazy var conditionsOfSaleAddress = "http://artsy.net/conditions-of-sale"
    lazy var privacyPolicyAddress = "http://artsy.net/privacy"

    class func instantiateFromStoryboard() -> PlaceBidViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.PlaceYourBid) as PlaceBidViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if !hasAlreadyPlacedABid {
            self.fulfillmentNav().reset()
        }

        let keypad = self.keypadContainer!.keypad!
        let bidDollarsSignal = RACObserve(self, "bidDollars")
        let bidIsZeroSignal = bidDollarsSignal.map { return ($0 as Int == 0) }

        for button in [keypad.rightButton, keypad.leftButton] {
            RAC(button, "enabled") <~ bidIsZeroSignal.notEach()
        }

        let formattedBidTextSignal = RACObserve(self, "bidDollars").map(dollarsToCurrencyString)

        RAC(bidAmountTextField, "text") <~ RACSignal.`if`(bidIsZeroSignal, then: RACSignal.defer{ RACSignal.`return`("") }, `else`: formattedBidTextSignal)

        keypadSignal.subscribeNext(addDigitToBid)
        deleteSignal.subscribeNext(deleteBid)
        clearSignal.subscribeNext(clearBid)

        if let nav = self.navigationController as? FulfillmentNavigationController {
            RAC(nav.bidDetails, "bidAmountCents") <~ bidDollarsSignal.map { $0 as Float * 100 }.takeUntil(dissapearSignal())

            if let saleArtwork:SaleArtwork = nav.bidDetails.saleArtwork {
                
                let minimumNextBidSignal = RACObserve(saleArtwork, "minimumNextBidCents")
                let bidCountSignal = RACObserve(saleArtwork, "bidCount")
                let openingBidSignal = RACObserve(saleArtwork, "openingBidCents")
                let highestBidSignal = RACObserve(saleArtwork, "highestBidCents")

                RAC(currentBidTitleLabel, "text") <~ bidCountSignal.map(toCurrentBidTitleString)
                RAC(nextBidAmountLabel, "text") <~ minimumNextBidSignal.map(toNextBidString)

                RAC(currentBidAmountLabel, "text") <~ RACSignal.combineLatest([bidCountSignal, highestBidSignal, openingBidSignal]).map {
                    let tuple = $0 as RACTuple
                    let bidCount = tuple.first as? Int ?? 0
                    return (bidCount > 0 ? tuple.second : tuple.third) ?? 0
                }.map(centsToPresentableDollarsString).takeUntil(dissapearSignal())

                RAC(bidButton, "enabled") <~ RACSignal.combineLatest([bidDollarsSignal, minimumNextBidSignal]).map {
                    let tuple = $0 as RACTuple
                    return (tuple.first as? Int ?? 0) * 100 >= (tuple.second as? Int ?? 0)
                }

                if let artist = saleArtwork.artwork.artists?.first {
                    RAC(artistNameLabel, "text") <~ RACObserve(artist, "name")
                }

                RAC(artworkTitleLabel, "attributedText") <~ RACObserve(saleArtwork.artwork, "titleAndDate").takeUntil(rac_willDeallocSignal())
                RAC(artworkPriceLabel, "text") <~ RACObserve(saleArtwork.artwork, "price").takeUntil(dissapearSignal())
                
                RACObserve(saleArtwork, "artwork").subscribeNext { [weak self] (artwork) -> Void in
                    if let url = (artwork as? Artwork)?.images?.first?.thumbnailURL() {
                        self?.artworkImageView.sd_setImageWithURL(url)
                    } else {
                        self?.artworkImageView.image = nil
                    }
                }
            }
        }
    }

    func dissapearSignal() -> RACSignal {
        return rac_signalForSelector("viewDidDisappear:")
    }

    @IBOutlet var bidButton: Button!
    @IBAction func bidButtonTapped(sender: AnyObject) {
        let identifier = hasAlreadyPlacedABid ? SegueIdentifier.PlaceAnotherBid : SegueIdentifier.ConfirmBid
        performSegue(identifier)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue == .PlaceAnotherBid {
            let nextViewController = segue.destinationViewController as LoadingViewController
            nextViewController.placingBid = true
        }
    }


    @IBAction func conditionsTapped(sender: AnyObject) {
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.showConditionsOfSale()
    }

    @IBAction func privacyTapped(sender: AnyObject) {
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.showPrivacyPolicy()
    }

    lazy var keypadSignal:RACSignal! = self.keypadContainer.keypad?.keypadSignal
    lazy var clearSignal:RACSignal!  = self.keypadContainer.keypad?.rightSignal
    lazy var deleteSignal:RACSignal! = self.keypadContainer.keypad?.leftSignal
}

/// These are for RAC only

private extension PlaceBidViewController {

    func dollarsToCurrencyString(input: AnyObject!) -> AnyObject! {
        let formatter = NSNumberFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.numberStyle = .DecimalStyle
        return formatter.stringFromNumber(input as Int)
    }

    func addDigitToBid(input: AnyObject!) -> Void {
        let inputInt = input as? Int ?? 0
        let newBidDollars = (10 * self.bidDollars) + inputInt
        if (newBidDollars >= 1_000_000) { return }
        self.bidDollars = newBidDollars
    }

    func deleteBid(input: AnyObject!) -> Void {
        self.bidDollars = self.bidDollars/10
    }

    func clearBid(input: AnyObject!) -> Void {
        self.bidDollars = 0
    }

    func toCurrentBidTitleString(input: AnyObject!) -> AnyObject! {
        if let count = input as? Int {
            return count > 0 ? "Current Bid:" : "Opening Bid:"
        } else {
            return ""
        }
    }

    func toNextBidString(cents: AnyObject!) -> AnyObject! {
        if let dollars = NSNumberFormatter.currencyStringForCents(cents as? Int) {
            return "Enter \(dollars) or more"
        }
        return ""
    }
}
