import UIKit
import ORStackView
import Artsy_UILabels
import Artsy_UIFonts
import RxSwift
import Artsy_UIButtons
import SDWebImage
import Action

class SaleArtworkDetailsViewController: UIViewController {
    var allowAnimations = true
    var auctionID = AppSetup.sharedState.auctionID
    var saleArtwork: SaleArtwork!
    var provider: Provider!
    
    var showBuyersPremiumCommand = { () -> CocoaAction in
        appDelegate().showBuyersPremiumCommand()
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> SaleArtworkDetailsViewController {
        return storyboard.viewControllerWithID(.SaleArtworkDetail) as! SaleArtworkDetailsViewController
    }

    lazy var artistInfo: Observable<AnyObject> = {
        let artistInfo = self.provider.request(.Artwork(id: self.saleArtwork.artwork.id)).filterSuccessfulStatusCodes().mapJSON()
        return artistInfo.shareReplay(1)
    }()
    
    @IBOutlet weak var metadataStackView: ORTagBasedAutoStackView!
    @IBOutlet weak var additionalDetailScrollView: ORStackScrollView!

    var buyersPremium: () -> (BuyersPremium?) = { appDelegate().sale.buyersPremium }
    let layoutSubviews = PublishSubject<Void>()
    let viewWillAppear = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMetadataView()
        setupAdditionalDetailStackView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // OK, so this is pretty weird, eh? So basically we need to be notified of layout changes _just after_ the layout
        // is actually done. For whatever reason, the UIKit hack to get the labels to adhere to their proper width only
        // works if we defer recalculating their geometry to the next runloop.
        // This wasn't an issue with RAC's rac_signalForSelector because that invoked the signal _after_ this method completed.
        // So that's what I've done here.
        dispatch_async(dispatch_get_main_queue()) {
            self.layoutSubviews.onNext()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        viewWillAppear.onCompleted()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .ZoomIntoArtwork {
            let nextViewController = segue.destinationViewController as! SaleArtworkZoomViewController
            nextViewController.saleArtwork = saleArtwork
        }
    }

    enum MetadataStackViewTag: Int {
        case LotNumberLabel = 1
        case ArtistNameLabel
        case ArtworkNameLabel
        case ArtworkMediumLabel
        case ArtworkDimensionsLabel
        case ImageRightsLabel
        case EstimateTopBorder
        case EstimateLabel
        case EstimateBottomBorder
        case CurrentBidLabel
        case CurrentBidValueLabel
        case NumberOfBidsPlacedLabel
        case BidButton
        case BuyersPremium
    }

    @IBAction func backWasPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    private func setupMetadataView() {
        enum LabelType {
            case Serif
            case SansSerif
            case ItalicsSerif
            case Bold
        }

        func label(type: LabelType, tag: MetadataStackViewTag, fontSize: CGFloat = 16.0) -> UILabel {
            let label: UILabel = { () -> UILabel in
                switch type {
                case .Serif:
                    return ARSerifLabel()
                case .SansSerif:
                    return ARSansSerifLabel()
                case .ItalicsSerif:
                    return ARItalicsSerifLabel()
                case .Bold:
                    let label = ARSerifLabel()
                    label.font = UIFont.sansSerifFontWithSize(label.font.pointSize)
                    return label
                }
            }()

            label.lineBreakMode = .ByWordWrapping
            label.font = label.font.fontWithSize(fontSize)
            label.tag = tag.rawValue
            label.preferredMaxLayoutWidth = 276

            return label
        }

        let hasLotNumber = (saleArtwork.lotNumber != nil)

        if let _ = saleArtwork.lotNumber {
            let lotNumberLabel = label(.SansSerif, tag: .LotNumberLabel)
            lotNumberLabel.font = lotNumberLabel.font.fontWithSize(12)
            metadataStackView.addSubview(lotNumberLabel, withTopMargin: "0", sideMargin: "0")

            saleArtwork
                .viewModel
                .lotNumber()
                .filterNil()
                .bindTo(lotNumberLabel.rx_text)
                .addDisposableTo(rx_disposeBag)
        }

        if let artist = artist() {
            let artistNameLabel = label(.SansSerif, tag: .ArtistNameLabel)
            artistNameLabel.text = artist.name
            metadataStackView.addSubview(artistNameLabel, withTopMargin: hasLotNumber ? "10" : "0", sideMargin: "0")
        }

        let artworkNameLabel = label(.ItalicsSerif, tag: .ArtworkNameLabel)
        artworkNameLabel.text = "\(saleArtwork.artwork.title), \(saleArtwork.artwork.date)"
        metadataStackView.addSubview(artworkNameLabel, withTopMargin: "10", sideMargin: "0")

        if let medium = saleArtwork.artwork.medium {
            if medium.isNotEmpty {
                let mediumLabel = label(.Serif, tag: .ArtworkMediumLabel)
                mediumLabel.text = medium
                metadataStackView.addSubview(mediumLabel, withTopMargin: "22", sideMargin: "0")
            }
        }

        if saleArtwork.artwork.dimensions.count > 0 {
            let dimensionsLabel = label(.Serif, tag: .ArtworkDimensionsLabel)
            dimensionsLabel.text = (saleArtwork.artwork.dimensions as NSArray).componentsJoinedByString("\n")
            metadataStackView.addSubview(dimensionsLabel, withTopMargin: "5", sideMargin: "0")
        }

        retrieveImageRights()
            .filter { imageRights -> Bool in
                return imageRights.isNotEmpty
            }.subscribeNext { [weak self] imageRights in
                let rightsLabel = label(.Serif, tag: .ImageRightsLabel)
                rightsLabel.text = imageRights
                self?.metadataStackView.addSubview(rightsLabel, withTopMargin: "22", sideMargin: "0")
            }
            .addDisposableTo(rx_disposeBag)

        let estimateTopBorder = UIView()
        estimateTopBorder.constrainHeight("1")
        estimateTopBorder.tag = MetadataStackViewTag.EstimateTopBorder.rawValue
        metadataStackView.addSubview(estimateTopBorder, withTopMargin: "22", sideMargin: "0")

        let estimateLabel = label(.Serif, tag: .EstimateLabel)
        estimateLabel.text = saleArtwork.viewModel.estimateString
        metadataStackView.addSubview(estimateLabel, withTopMargin: "15", sideMargin: "0")

        let estimateBottomBorder = UIView()
        estimateBottomBorder.constrainHeight("1")
        estimateBottomBorder.tag = MetadataStackViewTag.EstimateBottomBorder.rawValue
        metadataStackView.addSubview(estimateBottomBorder, withTopMargin: "10", sideMargin: "0")

        viewWillAppear
            .subscribeCompleted { [weak estimateTopBorder, weak estimateBottomBorder] in
                estimateTopBorder?.drawDottedBorders()
                estimateBottomBorder?.drawDottedBorders()
            }
            .addDisposableTo(rx_disposeBag)

        let hasBids = saleArtwork
            .rx_observe(NSNumber.self, "highestBidCents")
            .map { observeredCents -> Bool in
                guard let cents = observeredCents else { return false }
                return (cents as Int ?? 0) > 0
            }

        let currentBidLabel = label(.Serif, tag: .CurrentBidLabel)

        hasBids
            .flatMap { hasBids -> Observable<String> in
                if hasBids {
                    return just("Current Bid:")
                } else {
                    return just("Starting Bid:")
                }
            }
            .bindTo(currentBidLabel.rx_text)
            .addDisposableTo(rx_disposeBag)

        metadataStackView.addSubview(currentBidLabel, withTopMargin: "22", sideMargin: "0")

        let currentBidValueLabel = label(.Bold, tag: .CurrentBidValueLabel, fontSize: 27)
        saleArtwork
            .viewModel
            .currentBid()
            .bindTo(currentBidValueLabel.rx_text)
            .addDisposableTo(rx_disposeBag)
        metadataStackView.addSubview(currentBidValueLabel, withTopMargin: "10", sideMargin: "0")

        let numberOfBidsPlacedLabel = label(.Serif, tag: .NumberOfBidsPlacedLabel)
        saleArtwork
            .viewModel
            .numberOfBidsWithReserve
            .bindTo(numberOfBidsPlacedLabel.rx_text)
            .addDisposableTo(rx_disposeBag)
        metadataStackView.addSubview(numberOfBidsPlacedLabel, withTopMargin: "10", sideMargin: "0")

        let bidButton = ActionButton()
        bidButton
            .rx_tap
            .asObservable()
            .subscribeNext { [weak self] _ in
                guard let me = self else { return }

                me.bid(me.auctionID, saleArtwork: me.saleArtwork, allowAnimations: me.allowAnimations, provider: me.provider)
            }
            .addDisposableTo(rx_disposeBag)

        saleArtwork
            .viewModel
            .forSale()
            .subscribeNext { [weak bidButton] forSale in
                let forSale = forSale

                let title = forSale ? "BID" : "SOLD"
                bidButton?.setTitle(title, forState: .Normal)
            }
            .addDisposableTo(rx_disposeBag)

        saleArtwork
            .viewModel
            .forSale()
            .bindTo(bidButton.rx_enabled)
            .addDisposableTo(rx_disposeBag)

        bidButton.tag = MetadataStackViewTag.BidButton.rawValue
        metadataStackView.addSubview(bidButton, withTopMargin: "40", sideMargin: "0")

        if let _ = buyersPremium() {
            let buyersPremiumView = UIView()
            buyersPremiumView.tag = MetadataStackViewTag.BuyersPremium.rawValue

            let buyersPremiumLabel = ARSerifLabel()
            buyersPremiumLabel.font = buyersPremiumLabel.font.fontWithSize(16)
            buyersPremiumLabel.text = "This work has a "
            buyersPremiumLabel.textColor = .artsyHeavyGrey()

            let buyersPremiumButton = ARButton()
            let title = "buyers premium"
            let attributes: [String: AnyObject] = [ NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSFontAttributeName: buyersPremiumLabel.font ];
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            buyersPremiumButton.setTitle(title, forState: .Normal)
            buyersPremiumButton.titleLabel?.attributedText = attributedTitle;
            buyersPremiumButton.setTitleColor(.artsyHeavyGrey(), forState: .Normal)

            buyersPremiumButton.rx_action = showBuyersPremiumCommand()

            buyersPremiumView.addSubview(buyersPremiumLabel)
            buyersPremiumView.addSubview(buyersPremiumButton)

            buyersPremiumLabel.alignTop("0", leading: "0", bottom: "0", trailing: nil, toView: buyersPremiumView)
            buyersPremiumLabel.alignBaselineWithView(buyersPremiumButton, predicate: nil)
            buyersPremiumButton.alignAttribute(.Left, toAttribute: .Right, ofView: buyersPremiumLabel, predicate: "0")

            metadataStackView.addSubview(buyersPremiumView, withTopMargin: "30", sideMargin: "0")
        }

        metadataStackView.bottomMarginHeight = CGFloat(NSNotFound)
    }

    private func setupImageView(imageView: UIImageView) {
        if let image = saleArtwork.artwork.defaultImage {

            // We'll try to retrieve the thumbnail image from the cache. If we don't have it, we'll set the background colour to grey to indicate that we're downloading it.
            let key = SDWebImageManager.sharedManager().cacheKeyForURL(image.thumbnailURL())
            let thumbnailImage = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(key)
            if thumbnailImage == nil {
                imageView.backgroundColor = .artsyLightGrey()
            }

            imageView.sd_setImageWithURL(image.fullsizeURL(), placeholderImage: thumbnailImage) { (image, _, _, _) in
                // If the image was successfully downloaded, make sure we aren't still displaying grey.
                if image != nil {
                    imageView.backgroundColor = .clearColor()
                }
            }

            let heightConstraintNumber = { () -> CGFloat in
                if let aspectRatio = image.aspectRatio {
                    if aspectRatio != 0 {
                        return min(400, CGFloat(538) / aspectRatio)
                    }
                }
                return 400
            }()
            imageView.constrainHeight( "\(heightConstraintNumber)" )

            imageView.contentMode = .ScaleAspectFit
            imageView.userInteractionEnabled = true

            let recognizer = UITapGestureRecognizer()
            imageView.addGestureRecognizer(recognizer)
            recognizer
                .rx_event
                .asObservable()
                .subscribeNext() { [weak self] _ in
                     self?.performSegue(.ZoomIntoArtwork)
                }
                .addDisposableTo(rx_disposeBag)
        }
    }

    private func setupAdditionalDetailStackView() {
        enum LabelType {
            case Header
            case Body
        }

        func label(type: LabelType, layout: Observable<Void>? = nil) -> UILabel {
            let (label, fontSize) = { () -> (UILabel, CGFloat) in
                switch type {
                case .Header:
                    return (ARSansSerifLabel(), 14)
                case .Body:
                    return (ARSerifLabel(), 16)
                }
            }()

            label.font = label.font.fontWithSize(fontSize)
            label.lineBreakMode = .ByWordWrapping

            layout?
                .take(1)
                .subscribeNext { [weak label] (_) in
                    if let label = label {
                        label.preferredMaxLayoutWidth = CGRectGetWidth(label.frame)
                    }
                }
                .addDisposableTo(rx_disposeBag)

            return label
        }

        additionalDetailScrollView.stackView.bottomMarginHeight = 40

        let imageView = UIImageView()
        additionalDetailScrollView.stackView.addSubview(imageView, withTopMargin: "0", sideMargin: "40")
        setupImageView(imageView)

        let additionalInfoHeaderLabel = label(.Header)
        additionalInfoHeaderLabel.text = "Additional Information"
        additionalDetailScrollView.stackView.addSubview(additionalInfoHeaderLabel, withTopMargin: "20", sideMargin: "40")

        if let blurb = saleArtwork.artwork.blurb {
            let blurbLabel = label(.Body, layout: layoutSubviews)
            blurbLabel.attributedText = MarkdownParser().attributedStringFromMarkdownString( blurb )
            additionalDetailScrollView.stackView.addSubview(blurbLabel, withTopMargin: "22", sideMargin: "40")
        }

        let additionalInfoLabel = label(.Body, layout: layoutSubviews)
        additionalInfoLabel.attributedText = MarkdownParser().attributedStringFromMarkdownString( saleArtwork.artwork.additionalInfo )
        additionalDetailScrollView.stackView.addSubview(additionalInfoLabel, withTopMargin: "22", sideMargin: "40")

        retrieveAdditionalInfo()
            .filter { info in
                return info.isNotEmpty
            }.subscribeNext { [weak self] info in
                additionalInfoLabel.attributedText = MarkdownParser().attributedStringFromMarkdownString(info)
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }
            .addDisposableTo(rx_disposeBag)

        if let artist = artist() {
            retrieveArtistBlurb()
                .filter { blurb in
                    return blurb.isNotEmpty
                }
                .subscribeNext { [weak self] blurb in
                    guard let me = self else { return }

                    let aboutArtistHeaderLabel = label(.Header)
                    aboutArtistHeaderLabel.text = "About \(artist.name)"
                    me.additionalDetailScrollView.stackView.addSubview(aboutArtistHeaderLabel, withTopMargin: "22", sideMargin: "40")

                    let aboutAristLabel = label(.Body, layout: me.layoutSubviews)
                    aboutAristLabel.attributedText = MarkdownParser().attributedStringFromMarkdownString(blurb)
                    me.additionalDetailScrollView.stackView.addSubview(aboutAristLabel, withTopMargin: "22", sideMargin: "40")
                }
                .addDisposableTo(rx_disposeBag)
        }
    }

    private func artist() -> Artist? {
        return saleArtwork.artwork.artists?.first
    }

    private func retrieveImageRights() -> Observable<String> {
        let artwork = saleArtwork.artwork

        if let imageRights = artwork.imageRights {
            return just(imageRights)

        } else {
            return artistInfo.map{ json in
                    return json["image_rights"] as? String
                }
                .filterNil()
                .doOnNext { imageRights in
                    artwork.imageRights = imageRights
                }
        }
    }

    private func retrieveAdditionalInfo() -> Observable<String> {
        let artwork = saleArtwork.artwork

        if let additionalInfo = artwork.additionalInfo {
            return just(additionalInfo)
        } else {
            return artistInfo.map{ json in
                    return json["additional_information"] as? String
                }
                .filterNil()
                .doOnNext{ info in
                    artwork.additionalInfo = info
                }
        }
    }

    private func retrieveArtistBlurb() -> Observable<String> {
        guard let artist = artist() else {
            return empty()
        }

        if let blurb = artist.blurb {
            return just(blurb)
        } else {
            let retrieveArtist = provider.request(.Artist(id: artist.id))
                .filterSuccessfulStatusCodes()
                .mapJSON()

            return retrieveArtist.map{ json in
                    return json["blurb"] as? String
                }
                .filterNil()
                .doOnNext{ blurb in
                    artist.blurb = blurb
                }
        }
    }
}
