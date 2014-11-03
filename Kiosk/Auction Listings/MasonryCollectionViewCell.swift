import UIKit

let MasonryCollectionViewCellWidth: CGFloat = 254

class MasonryCollectionViewCell: ListingsCollectionViewCell {
    private lazy var bidView: UIView = {
        let view = UIView()
        for subview in [self.currentBidLabel, self.numberOfBidsLabel] {
            view.addSubview(subview)
            subview.alignTopEdgeWithView(view, predicate:"13")
            subview.alignBottomEdgeWithView(view, predicate:"0")
            subview.constrainHeight("18")
        }
        self.currentBidLabel.alignLeadingEdgeWithView(view, predicate: "0")
        self.numberOfBidsLabel.alignTrailingEdgeWithView(view, predicate: "0")
        return view
    }()
    
    private lazy var cellSubviews: [UIView] = [self.artworkImageView, self.artistNameLabel, self.artworkTitleLabel, self.estimateLabel, self.bidView, self.bidButton, self.moreInfoButton]

    private var artworkImageViewHeightConstraint: NSLayoutConstraint?
    
    override func setup() {
        super.setup()
        
        contentView.constrainWidth("\(MasonryCollectionViewCellWidth)")
        
        // Add subviews
        for subview in cellSubviews {
            self.contentView.addSubview(subview)
            subview.alignLeading("0", trailing: "0", toView: self.contentView)
        }
        
        // Constrain subviews
        artworkImageView.alignTop("0", bottom: nil, toView: contentView)
        artistNameLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: artworkImageView, predicate: "20")
        artistNameLabel.constrainHeight("20")
        artworkTitleLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: artistNameLabel, predicate: "10")
        artworkTitleLabel.constrainHeight("16")
        estimateLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: artworkTitleLabel, predicate: "10")
        estimateLabel.constrainHeight("16")
        bidView.alignAttribute(.Top, toAttribute: .Bottom, ofView: estimateLabel, predicate: "13")
        bidButton.alignAttribute(.Top, toAttribute: .Bottom, ofView: currentBidLabel, predicate: "13")
        moreInfoButton.alignAttribute(.Top, toAttribute: .Bottom, ofView: bidButton, predicate: "0")
        moreInfoButton.constrainHeight("44")
        moreInfoButton.alignAttribute(.Bottom, toAttribute: .Bottom, ofView: contentView, predicate: "00")
        
        // Bind subviews
        
        RACObserve(self, "saleArtwork").subscribeNext { [weak self] (saleArtwork) -> Void in
            if let saleArtwork = saleArtwork as? SaleArtwork {
                if let artworkImageViewHeightConstraint = self?.artworkImageViewHeightConstraint {
                    self?.artworkImageView.removeConstraint(artworkImageViewHeightConstraint)
                }
                let imageHeight = heightForImageWithAspectRatio(saleArtwork.artwork.images?.first?.aspectRatio)
                self?.artworkImageViewHeightConstraint = self?.artworkImageView.constrainHeight("\(imageHeight)").first as? NSLayoutConstraint
                self?.layoutIfNeeded()
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bidView.drawTopDottedBorderWithColor(UIColor.artsyMediumGrey())
    }
}

extension MasonryCollectionViewCell {
    class func heightForSaleArtwork(saleArtwork: SaleArtwork) -> CGFloat {
        let imageHeight = heightForImageWithAspectRatio(saleArtwork.artwork.images?.first?.aspectRatio)
        let remainingHeight =
            20 + // padding
            20 + // artist name
            10 + // padding
            16 + // artwork name
            10 + // padding
            16 + // estimate
            13 + // padding
            13 + // padding
            16 + // bid
            13 + // padding
            44   // more info button
        
        return imageHeight + ButtonHeight + CGFloat(remainingHeight)
    }
}

private func heightForImageWithAspectRatio(aspectRatio: CGFloat?) -> CGFloat {
    if let ratio = aspectRatio {
        return CGFloat(MasonryCollectionViewCellWidth) / ratio
    }
    return CGFloat(MasonryCollectionViewCellWidth)
}
