import UIKit
import Artsy_UILabels
import ReactiveCocoa
import Swift_RAC_Macros
import Artsy_UIButtons
import Artsy_UILabels
import ORStackView

class PlaceBidViewController: UIViewController {

    dynamic var bidDollars: Int = 0
    var hasAlreadyPlacedABid: Bool = false

    @IBOutlet var bidAmountTextField: TextField!
    @IBOutlet var cursor: CursorView!
    @IBOutlet var keypadContainer: KeypadContainerView!

    @IBOutlet var currentBidTitleLabel: UILabel!
    @IBOutlet var yourBidTitleLabel: UILabel!
    @IBOutlet var currentBidAmountLabel: UILabel!
    @IBOutlet var nextBidAmountLabel: UILabel!

    @IBOutlet var artworkImageView: UIImageView!
    @IBOutlet weak var detailsStackView: ORTagBasedAutoStackView!

    @IBOutlet var bidButton: Button!
    @IBOutlet weak var conditionsOfSaleButton: UIButton!
    @IBOutlet weak var privacyPolictyButton: UIButton!

    var showBuyersPremiumCommand = { () -> RACCommand in
        appDelegate().showBuyersPremiumCommand()
    }

    var showPrivacyPolicyCommand = { () -> RACCommand in
        appDelegate().showPrivacyPolicyCommand()
    }
    
    var showConditionsOfSaleCommand = { () -> RACCommand in
        appDelegate().showConditionsOfSaleCommand()
    }
    
    lazy var bidDollarsSignal: RACSignal = { self.keypadContainer.intValueSignal }()
    var buyersPremium: () -> (BuyersPremium?) = { appDelegate().sale.buyersPremium }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> PlaceBidViewController {
        return storyboard.viewControllerWithID(.PlaceYourBid) as! PlaceBidViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !hasAlreadyPlacedABid {
            self.fulfillmentNav().reset()
        }

        currentBidTitleLabel.font = UIFont.serifSemiBoldFontWithSize(17)
        yourBidTitleLabel.font = UIFont.serifSemiBoldFontWithSize(17)

        conditionsOfSaleButton.rac_command = showConditionsOfSaleCommand()
        privacyPolictyButton.rac_command = showPrivacyPolicyCommand()

        RAC(self, "bidDollars") <~ bidDollarsSignal

        RAC(bidAmountTextField, "text") <~ bidDollarsSignal.map(dollarsToCurrencyString)

        if let nav = self.navigationController as? FulfillmentNavigationController {
            RAC(nav.bidDetails, "bidAmountCents") <~ bidDollarsSignal.map { $0 as! Float * 100 }.takeUntil(viewWillDisappearSignal())

            if let saleArtwork = nav.bidDetails.saleArtwork {
                
                let minimumNextBidSignal = RACObserve(saleArtwork, "minimumNextBidCents")
                let bidCountSignal = RACObserve(saleArtwork, "bidCount")
                let openingBidSignal = RACObserve(saleArtwork, "openingBidCents")
                let highestBidSignal = RACObserve(saleArtwork, "highestBidCents")

                RAC(currentBidTitleLabel, "text") <~ bidCountSignal.map(toCurrentBidTitleString)
                RAC(nextBidAmountLabel, "text") <~ minimumNextBidSignal.map(toNextBidString)

                RAC(currentBidAmountLabel, "text") <~ RACSignal.combineLatest([bidCountSignal, highestBidSignal, openingBidSignal]).map {
                    let tuple = $0 as! RACTuple
                    let bidCount = tuple.first as? Int ?? 0
                    return (bidCount > 0 ? tuple.second : tuple.third) ?? 0
                }.map(centsToPresentableDollarsString).takeUntil(viewWillDisappearSignal())

                RAC(bidButton, "enabled") <~ RACSignal.combineLatest([bidDollarsSignal, minimumNextBidSignal]).map {
                    let tuple = $0 as! RACTuple
                    return (tuple.first as? Int ?? 0) * 100 >= (tuple.second as? Int ?? 0)
                }

                enum LabelTags: Int {
                    case LotNumber = 1
                    case ArtistName
                    case ArtworkTitle
                    case ArtworkPrice
                    case BuyersPremium
                    case Gobbler
                }

                let lotNumber = nav.bidDetails.saleArtwork?.lotNumber

                if let _ = lotNumber {
                    let lotNumberLabel = smallSansSerifLabel()
                    lotNumberLabel.tag = LabelTags.LotNumber.rawValue
                    detailsStackView.addSubview(lotNumberLabel, withTopMargin: "10", sideMargin: "0")
                    RAC(lotNumberLabel, "text") <~ saleArtwork.viewModel.lotNumberSignal.takeUntil(viewWillDisappearSignal())
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

                if let _ = buyersPremium() {
                    let buyersPremiumView = UIView()
                    buyersPremiumView.tag = LabelTags.BuyersPremium.rawValue

                    let buyersPremiumLabel = ARSerifLabel()
                    buyersPremiumLabel.font = buyersPremiumLabel.font.fontWithSize(16)
                    buyersPremiumLabel.text = "This work has a "
                    buyersPremiumLabel.textColor = .artsyHeavyGrey()

                    let buyersPremiumButton = ARUnderlineButton()
                    buyersPremiumButton.titleLabel?.font = buyersPremiumLabel.font
                    buyersPremiumButton.setTitle("buyers premium", forState: .Normal)
                    buyersPremiumButton.setTitleColor(.artsyHeavyGrey(), forState: .Normal)
                    buyersPremiumButton.rac_command = showBuyersPremiumCommand()

                    buyersPremiumView.addSubview(buyersPremiumLabel)
                    buyersPremiumView.addSubview(buyersPremiumButton)

                    buyersPremiumLabel.alignTop("0", leading: "0", bottom: "0", trailing: nil, toView: buyersPremiumView)
                    buyersPremiumLabel.alignBaselineWithView(buyersPremiumButton, predicate: nil)
                    buyersPremiumButton.alignAttribute(.Left, toAttribute: .Right, ofView: buyersPremiumLabel, predicate: "0")
                    
                    detailsStackView.addSubview(buyersPremiumView, withTopMargin: "15", sideMargin: "0")
                }

                let gobbler = WhitespaceGobbler()
                gobbler.tag = LabelTags.Gobbler.rawValue
                detailsStackView.addSubview(gobbler, withTopMargin: "0")

                if let artist = saleArtwork.artwork.artists?.first {
                    RAC(artistNameLabel, "text") <~ RACObserve(artist, "name")
                }

                RAC(artworkTitleLabel, "attributedText") <~ RACObserve(saleArtwork.artwork, "titleAndDate").takeUntil(rac_willDeallocSignal())
                RAC(artworkPriceLabel, "text") <~ RACObserve(saleArtwork.artwork, "price").takeUntil(viewWillDisappearSignal())
                
                RACObserve(saleArtwork, "artwork").subscribeNext { [weak self] (artwork) -> Void in
                    if let url = (artwork as? Artwork)?.defaultImage?.thumbnailURL() {
                        self?.artworkImageView.sd_setImageWithURL(url)
                    } else {
                        self?.artworkImageView.image = nil
                    }
                }
            }
        }
    }

    @IBAction func bidButtonTapped(sender: AnyObject) {
        let identifier = hasAlreadyPlacedABid ? SegueIdentifier.PlaceAnotherBid : SegueIdentifier.ConfirmBid
        performSegue(identifier)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue == .PlaceAnotherBid {
            let nextViewController = segue.destinationViewController as! LoadingViewController
            nextViewController.placingBid = true
        }
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

func dollarsToCurrencyString(input: AnyObject!) -> AnyObject! {
    let dollars = input as! Int
    if dollars == 0 {
        return ""
    }

    let formatter = NSNumberFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.numberStyle = .DecimalStyle
    return formatter.stringFromNumber(dollars)
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
