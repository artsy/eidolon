import UIKit
import Artsy_UILabels
import ReactiveCocoa
import Swift_RAC_Macros
import Artsy_UILabels
import ORStackView

public class PlaceBidViewController: UIViewController {

    public dynamic var bidDollars: Int = 0
    public var hasAlreadyPlacedABid: Bool = false

    @IBOutlet public var bidAmountTextField: TextField!
    @IBOutlet public var cursor: CursorView!
    @IBOutlet public var keypadContainer: KeypadContainerView!

    @IBOutlet public var currentBidTitleLabel: UILabel!
    @IBOutlet public var yourBidTitleLabel: UILabel!
    @IBOutlet public var currentBidAmountLabel: UILabel!
    @IBOutlet public var nextBidAmountLabel: UILabel!

    @IBOutlet public var artworkImageView: UIImageView!
    @IBOutlet weak var detailsStackView: ORTagBasedAutoStackView!

    @IBOutlet public var bidButton: Button!

    lazy public var conditionsOfSaleAddress = "http://artsy.net/conditions-of-sale"
    lazy public var privacyPolicyAddress = "http://artsy.net/privacy"
    
    lazy public var keypadSignal: RACSignal! = self.keypadContainer.keypad?.keypadSignal
    lazy public var clearSignal: RACSignal!  = self.keypadContainer.keypad?.rightSignal
    lazy public var deleteSignal: RACSignal! = self.keypadContainer.keypad?.leftSignal

    class public func instantiateFromStoryboard(storyboard: UIStoryboard) -> PlaceBidViewController {
        return storyboard.viewControllerWithID(.PlaceYourBid) as PlaceBidViewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if !hasAlreadyPlacedABid {
            self.fulfillmentNav().reset()
        }

        currentBidTitleLabel.font = UIFont.serifSemiBoldFontWithSize(17)
        yourBidTitleLabel.font = UIFont.serifSemiBoldFontWithSize(17)

        let keypad = self.keypadContainer!.keypad!
        let bidDollarsSignal = RACObserve(self, "bidDollars")
        let bidIsZeroSignal = bidDollarsSignal.map { return ($0 as Int == 0) }

        for button in [keypad.rightButton, keypad.leftButton] {
            RAC(button, "enabled") <~ bidIsZeroSignal.not()
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

                enum LabelTags: Int {
                    case LotNumber = 1
                    case ArtistName
                    case ArtworkTitle
                    case ArtworkPrice
                    case Gobbler
                }

                let lotNumber = nav.bidDetails.saleArtwork?.lotNumber

                if let lotNumber = lotNumber {
                    let lotNumberLabel = smallSansSerifLabel()
                    lotNumberLabel.tag = LabelTags.LotNumber.rawValue
                    detailsStackView.addSubview(lotNumberLabel, withTopMargin: "10", sideMargin: "0")
                    RAC(lotNumberLabel, "text") <~ RACObserve(saleArtwork, "lotNumber").map{
                        if let lotNumber = $0 as? NSNumber {
                            return "Lot \(lotNumber)"
                        } else {
                            return nil
                        }
                    }.mapNilToEmptyString().takeUntil(dissapearSignal())
                }

                let artistNameLabel = sansSerifLabel()
                artistNameLabel.tag = LabelTags.ArtistName.rawValue
                detailsStackView.addSubview(artistNameLabel, withTopMargin: "15", sideMargin: "0")

                let artworkTitleLabel = serifLabel()
                artworkTitleLabel.tag = LabelTags.ArtworkTitle.rawValue
                detailsStackView.addSubview(artworkTitleLabel, withTopMargin: "15", sideMargin: "0")

                let artworkPriceLabel = serifLabel()
                artworkPriceLabel.tag = LabelTags.ArtworkPrice.rawValue
                detailsStackView.addSubview(artworkPriceLabel, withTopMargin: "15", sideMargin: "0")

                let gobbler = WhitespaceGobbler()
                gobbler.tag = LabelTags.Gobbler.rawValue
                detailsStackView.addSubview(gobbler, withTopMargin: "0")

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

    @IBAction func bidButtonTapped(sender: AnyObject) {
        let identifier = hasAlreadyPlacedABid ? SegueIdentifier.PlaceAnotherBid : SegueIdentifier.ConfirmBid
        performSegue(identifier)
    }

    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

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
}

private extension PlaceBidViewController {
    func smallSansSerifLabel() -> UILabel {
        let label = sansSerifLabel()
        label.font = label.font.fontWithSize(12)
        return label
    }

    func sansSerifLabel() -> UILabel {
        let label = ARSansSerifLabel()
        label.numberOfLines = 1
        return label
    }

    func serifLabel() -> UILabel {
        let label = ARSerifLabel()
        label.numberOfLines = 1
        label.font = label.font.fontWithSize(16)
        return label
    }
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
        self.bidDollars = Int(self.bidDollars/10)
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
