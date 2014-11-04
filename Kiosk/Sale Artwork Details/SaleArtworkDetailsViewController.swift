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
    case CurrentBidView
    case BidButton
    case Gobbler
}

extension SaleArtworkDetailsViewController {
    @IBAction func backWasPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    private func setupMetadataView() {
        let artistNameLabel = ARSansSerifLabel()
        artistNameLabel.lineBreakMode = .ByWordWrapping
        artistNameLabel.text = saleArtwork.artwork.artists?.first?.name
        artistNameLabel.font = artistNameLabel.font.fontWithSize(16)
        artistNameLabel.tag = MetadataStackViewTag.ArtistNameLabel.rawValue
        metadataStackView.addSubview(artistNameLabel, withTopMargin: "0", sideMargin: "0")

        let artworkNameLabel = ARItalicsSerifLabel()
        artworkNameLabel.lineBreakMode = .ByWordWrapping
        artworkNameLabel.text = "\(saleArtwork.artwork.title), \(saleArtwork.artwork.date)"
        artworkNameLabel.font = artworkNameLabel.font.fontWithSize(16)
        artworkNameLabel.tag = MetadataStackViewTag.ArtworkNameLabel.rawValue
        metadataStackView.addSubview(artworkNameLabel, withTopMargin: "10", sideMargin: "0")

        if let medium = saleArtwork.artwork.medium {
            let mediumLabel = ARSerifLabel()
            mediumLabel.lineBreakMode = .ByWordWrapping
            mediumLabel.text = medium
            mediumLabel.font = mediumLabel.font.fontWithSize(16)
            mediumLabel.tag = MetadataStackViewTag.ArtworkMediumLabel.rawValue
            metadataStackView.addSubview(mediumLabel, withTopMargin: "22", sideMargin: "0")
        }

        if countElements(saleArtwork.artwork.dimensions) > 0 {
            
        }

        retrieveImageRights().subscribeNext { [weak self] (imageRights) -> Void in
            // TODO: rights label
        }

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

    private func retrieveBidHistory() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.BidHistory(auctionID: auctionID, artworkID: saleArtwork.artwork.id)
        return XAppRequest(endpoint, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON()
    }

    private func retrieveImageRights() -> RACSignal {
        let artwork = saleArtwork.artwork
        if let imageRights = artwork.imageRights {
            return RACSignal.`return`(imageRights)
        } else {
            let endpoint: ArtsyAPI = ArtsyAPI.Artwork(id: artwork.id)
            return XAppRequest(endpoint, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().map{ (json) -> AnyObject! in
                return json["image_rights"]
            }.doNext{ (imageRights) -> Void in
                artwork.imageRights = imageRights as? String
                return
            }
        }
    }
}
