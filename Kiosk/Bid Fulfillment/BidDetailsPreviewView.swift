import UIKit

class BidDetailsPreviewView: UIView {
    
    dynamic var bidDetails: BidDetails?

    dynamic let artworkImageView = UIImageViewAligned()
    dynamic let artistNameLabel = ARSansSerifLabel()
    dynamic let artworkTitleLabel = ARSerifLabel()
    dynamic let currentBidPriceLabel = ARSerifLabel()

    override func awakeFromNib() {
        self.backgroundColor = UIColor.whiteColor()
        
        artworkImageView.alignRight = true
        artworkImageView.alignBottom = true
        artworkImageView.contentMode = .ScaleAspectFit
        currentBidPriceLabel.font = UIFont.serifBoldFontWithSize(14)
        
        RACObserve(self, "bidDetails.saleArtwork.artwork").subscribeNext { [weak self] (artwork) -> Void in
            if let url = (artwork as? Artwork)?.images?.first?.thumbnailURL() {
                self?.artworkImageView.sd_setImageWithURL(url)
            } else {
                self?.artworkImageView.image = nil
            }
        }
        
        RAC(self, "artistNameLabel.text") <~ RACObserve(self, "bidDetails.saleArtwork.artwork").map({ (artwork) -> AnyObject! in
            return (artwork as? Artwork)?.artists?.first?.name
        }).mapNilToEmptyString()
        
        RAC(self, "artworkTitleLabel.attributedText") <~ RACObserve(self, "bidDetails.saleArtwork.artwork").map({ (artwork) -> AnyObject! in
            if let artwork = artwork as? Artwork {
                return artwork.titleAndDate
            } else {
                return nil
            }
        }).mapNilToEmptyAttributedString()

        RAC(self, "currentBidPriceLabel.text") <~ RACObserve(self, "bidDetails").map({ (bidDetails) -> AnyObject! in
            if let cents = (bidDetails as? BidDetails)?.bidAmountCents {
            	return "Your bid: " + NSNumberFormatter.currencyStringForCents(cents)
            }
            return nil
        }).mapNilToEmptyString()
        
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
