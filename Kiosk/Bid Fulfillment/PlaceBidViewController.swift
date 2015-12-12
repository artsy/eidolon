import UIKit
import Artsy_UILabels
import RxSwift
import Artsy_UIButtons
import Artsy_UILabels
import ORStackView
import Action

class PlaceBidViewController: UIViewController {

    // TODO: Can we abstract this into a superclass or something??
    var provider: Provider!

    private var _bidDollars = Variable(0)
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

    var showBuyersPremiumCommand = { () -> CocoaAction in
        appDelegate().showBuyersPremiumCommand()
    }

    var showPrivacyPolicyCommand = { () -> CocoaAction in
        appDelegate().showPrivacyPolicyCommand()
    }
    
    var showConditionsOfSaleCommand = { () -> CocoaAction in
        appDelegate().showConditionsOfSaleCommand()
    }
    
    lazy var bidDollars: Observable<Int> = { self.keypadContainer.intValue }()
    var buyersPremium: () -> (BuyersPremium?) = { appDelegate().sale.buyersPremium }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> PlaceBidViewController {
        return storyboard.viewControllerWithID(.PlaceYourBid) as! PlaceBidViewController
    }

    private let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !hasAlreadyPlacedABid {
            self.fulfillmentNav().reset()
        }

        currentBidTitleLabel.font = UIFont.serifSemiBoldFontWithSize(17)
        yourBidTitleLabel.font = UIFont.serifSemiBoldFontWithSize(17)

        conditionsOfSaleButton.rx_action = showConditionsOfSaleCommand()
        privacyPolictyButton.rx_action = showPrivacyPolicyCommand()

        bidDollars
            .bindTo(_bidDollars)
            .addDisposableTo(rx_disposeBag)

        bidDollars
            .map(dollarsToCurrencyString)
            .bindTo(bidAmountTextField.rx_text)
            .addDisposableTo(rx_disposeBag)


        if let nav = self.navigationController as? FulfillmentNavigationController {
            bidDollars
                .map { $0 * 100 }
                .takeUntil(viewWillDisappear)
                .bindTo(nav.bidDetails.bidAmountCents)
                .addDisposableTo(rx_disposeBag)

            if let saleArtwork = nav.bidDetails.saleArtwork {
                
                let minimumNextBid = saleArtwork
                    .rx_observe(NSNumber.self, "minimumNextBidCents")
                    .filterNil()
                    .map { $0 as Int }

                saleArtwork.viewModel
                    .currentBidOrOpeningBidLabel()
                    .bindTo(currentBidTitleLabel.rx_text)
                    .addDisposableTo(rx_disposeBag)

                saleArtwork.viewModel
                    .currentBidOrOpeningBid()
                    .bindTo(currentBidAmountLabel.rx_text)
                    .addDisposableTo(rx_disposeBag)


                minimumNextBid
                    .map { $0 as Int }
                    .map(toNextBidString)
                    .bindTo(nextBidAmountLabel.rx_text)
                    .addDisposableTo(rx_disposeBag)


                [bidDollars, minimumNextBid]
                    .combineLatest { ints in
                        return (ints[0]) * 100 >= (ints[1])
                    }
                    .bindTo(bidButton.rx_enabled)
                    .addDisposableTo(rx_disposeBag)


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
                    saleArtwork.viewModel
                        .lotNumber()
                        .filterNil()
                        .takeUntil(viewWillDisappear)
                        .bindTo(lotNumberLabel.rx_text)
                        .addDisposableTo(rx_disposeBag)

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
                    buyersPremiumButton.rx_action = showBuyersPremiumCommand()

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
                    artist
                        .rx_observe(String.self, "name")
                        .filterNil()
                        .bindTo(artistNameLabel.rx_text)
                        .addDisposableTo(rx_disposeBag)
                }

                saleArtwork
                    .artwork
                    .rx_observe(NSAttributedString.self, "titleAndDate")
                    .takeUntil(rx_deallocating)
                    .bindTo(artworkTitleLabel.rx_attributedText)
                    .addDisposableTo(rx_disposeBag)

                saleArtwork
                    .artwork
                    .rx_observe(String.self, "price")
                    .filterNil()
                    .takeUntil(rx_deallocating)
                    .bindTo(artworkPriceLabel.rx_text)
                    .addDisposableTo(rx_disposeBag)

                if let url = saleArtwork.artwork.defaultImage?.thumbnailURL() {
                    self.artworkImageView.sd_setImageWithURL(url)
                } else {
                    self.artworkImageView.image = nil
                }
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        _viewWillDisappear.onNext()
    }

    @IBAction func bidButtonTapped(sender: AnyObject) {
        let identifier = hasAlreadyPlacedABid ? SegueIdentifier.PlaceAnotherBid : SegueIdentifier.ConfirmBid
        performSegue(identifier)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue == .PlaceAnotherBid {
            let nextViewController = segue.destinationViewController as! LoadingViewController
            nextViewController.provider = provider
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

func dollarsToCurrencyString(dollars: Int) -> String {
    if dollars == 0 {
        return ""
    }

    let formatter = NSNumberFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.numberStyle = .DecimalStyle
    return formatter.stringFromNumber(dollars) ?? ""
}

func toNextBidString(cents: Int) -> String {
    guard let dollars = NSNumberFormatter.currencyStringForCents(cents)  else {
        return ""
    }
    return "Enter \(dollars) or more"
}
