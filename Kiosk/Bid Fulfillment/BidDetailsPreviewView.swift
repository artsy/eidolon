import UIKit
import Artsy_UILabels
import Artsy_UIButtons
import UIImageViewAligned
import RxSwift
import RxCocoa

class BidDetailsPreviewView: UIView {

    let _bidDetails = Variable<BidDetails?>(nil)
    var bidDetails: BidDetails? {
        didSet {
            self._bidDetails.value = bidDetails
        }
    }

    dynamic let artworkImageView = UIImageViewAligned()
    dynamic let artistNameLabel = ARSansSerifLabel()
    dynamic let artworkTitleLabel = ARSerifLabel()
    dynamic let currentBidPriceLabel = ARSerifLabel()

    override func awakeFromNib() {
        self.backgroundColor = .whiteColor()

        artistNameLabel.numberOfLines = 1
        artworkTitleLabel.numberOfLines = 1
        currentBidPriceLabel.numberOfLines = 1

        artworkImageView.alignRight = true
        artworkImageView.alignBottom = true
        artworkImageView.contentMode = .ScaleAspectFit

        artistNameLabel.font = UIFont.sansSerifFontWithSize(14)
        currentBidPriceLabel.font = UIFont.serifBoldFontWithSize(14)

        let artwork = _bidDetails
            .asObservable()
            .filterNil()
            .map { bidDetails in
                return bidDetails.saleArtwork?.artwork
            }
            .take(1)

        artwork
            .subscribeNext { [weak self] artwork in
                if let url = artwork?.defaultImage?.thumbnailURL() {
                    self?.bidDetails?.setImage(url: url, imageView: self!.artworkImageView)
                } else {
                    self?.artworkImageView.image = nil
                }
            }
            .addDisposableTo(rx_disposeBag)

        artwork
            .map { artwork in
                return artwork?.artists?.first?.name
            }
            .map { name in
                return name ?? ""
            }
            .bindTo(artistNameLabel.rx_text)
            .addDisposableTo(rx_disposeBag)

        artwork
            .map { artwork -> NSAttributedString in
                guard let artwork = artwork else {
                    return NSAttributedString()
                }

                return artwork.titleAndDate
            }
            .bindTo(artworkTitleLabel.rx_attributedText)
            .addDisposableTo(rx_disposeBag)

        _bidDetails
            .asObservable()
            .filterNil()
            .take(1)
            .map { bidDetails in
                guard let cents = bidDetails.bidAmountCents.value else { return "" }

                return "Your bid: " + NSNumberFormatter.currencyStringForCents(cents)
            }
            .bindTo(currentBidPriceLabel.rx_text)
            .addDisposableTo(rx_disposeBag)
        
        for subview in [artworkImageView, artistNameLabel, artworkTitleLabel, currentBidPriceLabel] {
            self.addSubview(subview)
        }
        
        self.constrainHeight("60")
        
        artworkImageView.alignTop("0", leading: "0", bottom: "0", trailing: nil, toView: self)
        artworkImageView.constrainWidth("84")
        artworkImageView.constrainHeight("60")

        artistNameLabel.alignAttribute(.Top, toAttribute: .Top, ofView: self, predicate: "0")
        artistNameLabel.constrainHeight("16")
        artworkTitleLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: artistNameLabel, predicate: "8")
        artworkTitleLabel.constrainHeight("16")
        currentBidPriceLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: artworkTitleLabel, predicate: "4")
        currentBidPriceLabel.constrainHeight("16")
        
        UIView.alignAttribute(.Leading, ofViews: [artistNameLabel, artworkTitleLabel, currentBidPriceLabel], toAttribute:.Trailing, ofViews: [artworkImageView, artworkImageView, artworkImageView], predicate: "20")
        UIView.alignAttribute(.Trailing, ofViews: [artistNameLabel, artworkTitleLabel, currentBidPriceLabel], toAttribute:.Trailing, ofViews: [self, self, self], predicate: "0")

    }

}
