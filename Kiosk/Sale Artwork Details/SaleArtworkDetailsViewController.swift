import UIKit
import ORStackView
import Artsy_UILabels
import Artsy_UIFonts

class SaleArtworkDetailsViewController: UIViewController {
    var allowAnimations = true
    var auctionID = AppSetup.sharedState.auctionID
    var saleArtwork: SaleArtwork!
    
    @IBOutlet weak var metadataStackView: ORTagBasedAutoStackView!
    @IBOutlet weak var additionalDetailScrollView: ORStackScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMetadataView()
        setupAdditionalDetailStackView()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .ZoomIntoArtwork {
            let nextViewController = segue.destinationViewController as SaleArtworkZoomViewController
            nextViewController.saleArtwork = saleArtwork
        }
    }
}

enum MetadataStackViewTag: Int {
    case ArtistNameLabel = 1
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
    case ReserveNotMetLabel
    case BidButton
    case Gobbler
}

extension SaleArtworkDetailsViewController {
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

        if let artist = artist() {
            let artistNameLabel = label(.SansSerif, .ArtistNameLabel)
            artistNameLabel.text = artist.name
            metadataStackView.addSubview(artistNameLabel, withTopMargin: "0", sideMargin: "0")
        }

        let artworkNameLabel = label(.ItalicsSerif, .ArtworkNameLabel)
        artworkNameLabel.text = "\(saleArtwork.artwork.title), \(saleArtwork.artwork.date)"
        metadataStackView.addSubview(artworkNameLabel, withTopMargin: "10", sideMargin: "0")

        if let medium = saleArtwork.artwork.medium {
            if countElements(medium) > 0 {
                let mediumLabel = label(.Serif, .ArtworkMediumLabel)
                mediumLabel.text = medium
                metadataStackView.addSubview(mediumLabel, withTopMargin: "22", sideMargin: "0")
            }
        }

        if countElements(saleArtwork.artwork.dimensions) > 0 {
            let dimensionsLabel = label(.Serif, .ArtworkDimensionsLabel)
            dimensionsLabel.text = (saleArtwork.artwork.dimensions as NSArray).componentsJoinedByString("\n")
            metadataStackView.addSubview(dimensionsLabel, withTopMargin: "5", sideMargin: "0")
        }

        retrieveImageRights().filter { (imageRights) -> Bool in
            return (countElements(imageRights as? String ?? "") > 0)

        }.subscribeNext { [weak self] (imageRights) -> Void in
            if countElements(imageRights as String) > 0 {
                let rightsLabel = label(.Serif, .ImageRightsLabel)
                rightsLabel.text = imageRights as? String
                self?.metadataStackView.addSubview(rightsLabel, withTopMargin: "22", sideMargin: "0")
            }
        }

        let estimateTopBorder = UIView()
        estimateTopBorder.constrainHeight("1")
        estimateTopBorder.tag = MetadataStackViewTag.EstimateTopBorder.rawValue
        metadataStackView.addSubview(estimateTopBorder, withTopMargin: "22", sideMargin: "0")

        let estimateLabel = label(.Serif, .EstimateLabel)
        estimateLabel.text = saleArtwork.estimateString
        metadataStackView.addSubview(estimateLabel, withTopMargin: "15", sideMargin: "0")

        let estimateBottomBorder = UIView()
        estimateBottomBorder.constrainHeight("1")
        estimateBottomBorder.tag = MetadataStackViewTag.EstimateBottomBorder.rawValue
        metadataStackView.addSubview(estimateBottomBorder, withTopMargin: "10", sideMargin: "0")

        rac_signalForSelector("viewDidLayoutSubviews").subscribeNext { [weak estimateTopBorder, weak estimateBottomBorder] (_) -> Void in
            estimateTopBorder?.drawDottedBorders()
            estimateBottomBorder?.drawDottedBorders()
        }

        let hasBidsSignal = RACObserve(saleArtwork, "highestBidCents").map{ (cents) -> AnyObject! in
            return (cents != nil) && ((cents as? NSNumber ?? 0) > 0)
        }
        let currentBidLabel = label(.Serif, .CurrentBidLabel)
        RAC(currentBidLabel, "text") <~ RACSignal.`if`(hasBidsSignal, then: RACSignal.`return`("Current Bid:"), `else`: RACSignal.`return`("Starting Bid:"))
        metadataStackView.addSubview(currentBidLabel, withTopMargin: "22", sideMargin: "0")

        let currentBidValueLabel = label(.Bold, .CurrentBidValueLabel, fontSize: 27)
        RAC(currentBidValueLabel, "text") <~ saleArtwork.currentBidSignal()
        metadataStackView.addSubview(currentBidValueLabel, withTopMargin: "10", sideMargin: "0")

        let numberOfBidsPlacedLabel = label(.Serif, .NumberOfBidsPlacedLabel)
        RAC(numberOfBidsPlacedLabel, "text") <~ saleArtwork.numberOfBidsSignal
        metadataStackView.addSubview(numberOfBidsPlacedLabel, withTopMargin: "10", sideMargin: "0")

        if saleArtwork.reserveNotMet {
            let reserveLabel = label(.Serif, .ReserveNotMetLabel)
            reserveLabel.text = "This work has a reserve"
            metadataStackView.addSubview(reserveLabel, withTopMargin: "5", sideMargin: "0")
        }

        let bidButton = ActionButton()
        bidButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self] (_) -> Void in
            if let strongSelf = self {
                strongSelf.bid(strongSelf.auctionID, saleArtwork: strongSelf.saleArtwork, allowAnimations: strongSelf.allowAnimations)
            }
        }
        bidButton.setTitle("Bid", forState: .Normal)
        bidButton.tag = MetadataStackViewTag.BidButton.rawValue
        metadataStackView.addSubview(bidButton, withTopMargin: "40", sideMargin: "0")

        metadataStackView.bottomMarginHeight = CGFloat(NSNotFound)
    }

    private func setupImageView(imageView: UIImageView) {
        if let image = saleArtwork.artwork.images?.first? {
            if let url = image.fullsizeURL() {
                imageView.sd_setImageWithURL(url, completed: { [weak self] image, error, type, url -> () in
                    imageView.backgroundColor = UIColor.clearColor()
                    return
                })
            }

            let heightConstraintNumber = min(400, CGFloat(538) / image.aspectRatio)
            imageView.constrainHeight( "\(heightConstraintNumber)" )

            imageView.contentMode = .ScaleAspectFit
            imageView.userInteractionEnabled = true

            let recognizer = UITapGestureRecognizer()
            imageView.addGestureRecognizer(recognizer)
            recognizer.rac_gestureSignal().subscribeNext() { [weak self] (_) in
                 self?.performSegue(.ZoomIntoArtwork)
                 return
            }
        }
    }

    private func setupAdditionalDetailStackView() {
        enum LabelType {
            case Header
            case Body
        }

        func label(type: LabelType, layoutSignal: RACSignal? = nil) -> UILabel {
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

            layoutSignal?.take(1).subscribeNext { [weak label] (_) -> Void in
                if let label = label {
                    label.preferredMaxLayoutWidth = CGRectGetWidth(label.frame)
                }
            }

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
            let blurbLabel = label(.Body, layoutSignal: additionalDetailScrollView.stackView.rac_signalForSelector("layoutSubviews"))
            blurbLabel.attributedText = MarkdownParser().attributedStringFromMarkdownString( blurb )
            additionalDetailScrollView.stackView.addSubview(blurbLabel, withTopMargin: "22", sideMargin: "40")
        }

        let additionalInfoLabel = label(.Body, layoutSignal: additionalDetailScrollView.stackView.rac_signalForSelector("layoutSubviews"))
        additionalInfoLabel.attributedText = MarkdownParser().attributedStringFromMarkdownString( saleArtwork.artwork.additionalInfo )
        additionalDetailScrollView.stackView.addSubview(additionalInfoLabel, withTopMargin: "22", sideMargin: "40")

        retrieveAdditionalInfo().filter { (info) -> Bool in
            return (countElements(info as? String ?? "") > 0)

            }.subscribeNext { [weak self] (info) -> Void in
                additionalInfoLabel.attributedText = MarkdownParser().attributedStringFromMarkdownString( info as String )
        }

        if let artist = artist() {
            retrieveArtistBlurb().filter { (blurb) -> Bool in
                return (countElements(blurb as? String ?? "") > 0)

                }.subscribeNext { [weak self] (blurb) -> Void in
                    if self == nil {
                        return
                    }
                    let aboutArtistHeaderLabel = label(.Header)
                    aboutArtistHeaderLabel.text = "About \(artist.name)"
                    self?.additionalDetailScrollView.stackView.addSubview(aboutArtistHeaderLabel, withTopMargin: "22", sideMargin: "40")

                    let aboutAristLabel = label(.Body, layoutSignal: self?.additionalDetailScrollView.stackView.rac_signalForSelector("layoutSubviews"))
                    aboutAristLabel.attributedText = MarkdownParser().attributedStringFromMarkdownString( blurb as? String )
                    self?.additionalDetailScrollView.stackView.addSubview(aboutAristLabel, withTopMargin: "22", sideMargin: "40")
            }
        }
    }

    private func artist() -> Artist? {
        return saleArtwork.artwork.artists?.first
    }

    private func retrieveImageRights() -> RACSignal {
        let artwork = saleArtwork.artwork

        if let imageRights = artwork.imageRights {
            return RACSignal.`return`(imageRights)

        } else {
            let endpoint: ArtsyAPI = ArtsyAPI.Artwork(id: artwork.id)
            return XAppRequest(endpoint, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().map{ (json) -> AnyObject! in
                return json["image_rights"]
            }.filter({ (imageRights) -> Bool in
                imageRights != nil
            }).doNext{ (imageRights) -> Void in
                artwork.imageRights = imageRights as? String
                return
            }
        }
    }

    // Duped code with ^ could be better?
    private func retrieveAdditionalInfo() -> RACSignal {
        let artwork = saleArtwork.artwork

        if let additionalInfo = artwork.additionalInfo {
            return RACSignal.`return`(additionalInfo)

        } else {
            let endpoint: ArtsyAPI = ArtsyAPI.Artwork(id: artwork.id)
            return XAppRequest(endpoint, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().map{ (json) -> AnyObject! in
                return json["additional_information"]
                }.filter({ (info) -> Bool in
                    info != nil
                }).doNext{ (info) -> Void in
                    artwork.additionalInfo = info as? String
                    return
            }
        }
    }

    private func retrieveArtistBlurb() -> RACSignal {
        if let artist = artist() {
            if let blurb = artist.blurb {
                return RACSignal.`return`(blurb)
            } else {
                let endpoint: ArtsyAPI = ArtsyAPI.Artist(id: artist.id)
                return XAppRequest(endpoint, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().map{ (json) -> AnyObject! in
                    return json["blurb"]
                    }.filter({ (blurb) -> Bool in
                        blurb != nil
                    }).doNext{ (blurb) -> Void in
                        artist.blurb = blurb as? String
                        return
                }
            }
        } else {
            return RACSignal.empty()
        }
    }
}
