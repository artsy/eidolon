import UIKit

class SaleArtworkDetailsViewController: UIViewController {
    var allowAnimations = true
    var auctionID = AppSetup.sharedState.auctionID
    var saleArtwork: SaleArtwork!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var metadataStackView: ORTagBasedAutoStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupImageView()
        setupMetadataView()
    }
}

enum MetadataStackViewTag: Int {
    case ArtistNameLabel = 1
    case ArtworkNameLabel
    case ArtworkMediumLabel
    case ArtworkDimensionsLabel
    case ImageRightsLabel
    case EstimateLabel
    case CurrentBidLabel
    case CurrentBidValueLabel
    case NumberOfBidsPlacedLabel
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

            return label
        }

        let artistNameLabel = label(.SansSerif, .ArtistNameLabel)
        artistNameLabel.text = saleArtwork.artwork.artists?.first?.name
        metadataStackView.addSubview(artistNameLabel, withTopMargin: "0", sideMargin: "0")

        let artworkNameLabel = label(.ItalicsSerif, .ArtworkNameLabel)
        artworkNameLabel.text = "\(saleArtwork.artwork.title), \(saleArtwork.artwork.date)"
        metadataStackView.addSubview(artworkNameLabel, withTopMargin: "10", sideMargin: "0")

        if let medium = saleArtwork.artwork.medium {
            let mediumLabel = label(.Serif, .ArtworkMediumLabel)
            mediumLabel.text = medium
            metadataStackView.addSubview(mediumLabel, withTopMargin: "22", sideMargin: "0")
        }

        if countElements(saleArtwork.artwork.dimensions) > 0 {
            let dimensionsLabel = label(.Serif, .ArtworkDimensionsLabel)
            dimensionsLabel.text = (saleArtwork.artwork.dimensions as NSArray).componentsJoinedByString("\n")
            metadataStackView.addSubview(dimensionsLabel, withTopMargin: "5", sideMargin: "0")
        }

        retrieveImageRights().filter { (imageRights) -> Bool in
            (countElements(imageRights as? String ?? "") > 0)
        }.subscribeNext { [weak self] (imageRights) -> Void in
            let rightsLabel = label(.Serif, .ImageRightsLabel)
            rightsLabel.text = imageRights as? String
            self?.metadataStackView.addSubview(rightsLabel, withTopMargin: "22", sideMargin: "0")
        }

        let estimateLabel = label(.Serif, .EstimateLabel)
        estimateLabel.constrainHeight("27")
        estimateLabel.text = saleArtwork.estimateString
        rac_signalForSelector("viewDidLayoutSubviews").subscribeNext { [weak estimateLabel] (_) -> Void in
            estimateLabel?.drawDottedBorders()
            return
        }
        metadataStackView.addSubview(estimateLabel, withTopMargin: "22", sideMargin: "0")

        let currentBidLabel = label(.Serif, .CurrentBidLabel)
        currentBidLabel.text = "Current Bid:"
        metadataStackView.addSubview(currentBidLabel, withTopMargin: "22", sideMargin: "0")

        let currentBidValueLabel = label(.Bold, .CurrentBidValueLabel, fontSize: 27)
        if let currentBidCents = saleArtwork.highestBidCents {
            currentBidValueLabel.text = NSNumberFormatter.currencyStringForCents(currentBidCents)
        } else {
            currentBidValueLabel.text = "No Bids"
        }
        metadataStackView.addSubview(currentBidValueLabel, withTopMargin: "10", sideMargin: "0")

        let numberOfBidsPlacedLabel = label(.Serif, .NumberOfBidsPlacedLabel)
        RAC(numberOfBidsPlacedLabel, "text") <~ saleArtwork.numberOfBidsSignal.takeUntil(rac_willDeallocSignal())
        metadataStackView.addSubview(numberOfBidsPlacedLabel, withTopMargin: "10", sideMargin: "0")

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

    private func setupImageView() {
        if let image = saleArtwork.artwork.images?.first? {
            if let url = image.fullsizeURL() {
                imageView.sd_setImageWithURL(url, completed: { [weak self] image, error, type, url -> () in
                    self?.imageView.backgroundColor = UIColor.clearColor()
                    return
                })
            }

            imageViewHeightConstraint.constant = min(400, CGFloat(538) / image.aspectRatio)
        }
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
}
