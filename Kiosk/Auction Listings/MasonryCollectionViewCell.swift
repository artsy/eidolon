import UIKit

let MasonryCollectionViewCellWidth: CGFloat = 254

class MasonryCollectionViewCell: ListingsCollectionViewCell {
    private lazy var bidView: UIView = {
        let view = UIView()
        view.addSubview(self.currentBidLabel)
        view.addSubview(self.numberOfBidsLabel)

        self.currentBidLabel.alignLeadingEdgeWithView(view, predicate: "0")
        self.numberOfBidsLabel.alignTrailingEdgeWithView(view, predicate: "0")
        UIView.alignBottomEdgesOfViews([view, self.currentBidLabel, self.numberOfBidsLabel])
        return view
    }()
    
    private lazy var cellSubviews: [UIView] = [self.artworkImageView, self.artistNameLabel, self.artworkTitleLabel, self.estimateLabel, self.dividerView, self.bidView, self.bidButton]
    private lazy var cellWidthSubviews: [UIView] = [self.artworkImageView, self.artistNameLabel, self.artworkTitleLabel, self.estimateLabel, self.bidView, self.dividerView, self.bidButton]
    
    private var artworkImageViewHeightConstraint: NSLayoutConstraint?
    
    override func setup() {
        super.setup()
        
        contentView.constrainWidth("\(MasonryCollectionViewCellWidth)")
        
        // Configure subviews
        // Need an explicit frame so that drawTopDottedBorder() is reliable
        dividerView.frame = CGRect(origin: CGPointZero, size: CGSize(width: MasonryCollectionViewCellWidth, height: 1))
        dividerView.drawTopDottedBorder()
        
        // Add subviews
        cellSubviews.map{ self.contentView.addSubview($0) }
        
        // Constrain subviews
        cellWidthSubviews.map { $0.alignLeading("0", trailing: "0", toView: self.contentView) }
        artworkImageView.alignTop("0", bottom: nil, toView: contentView)
        artistNameLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: artworkImageView, predicate: "20")
        artistNameLabel.constrainHeight("20")
        artworkTitleLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: artistNameLabel, predicate: "10")
        artworkTitleLabel.constrainHeight("16")
        estimateLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: artworkTitleLabel, predicate: "10")
        estimateLabel.constrainHeight("16")
        dividerView.alignAttribute(.Top, toAttribute: .Bottom, ofView: estimateLabel, predicate: "13")
        dividerView.constrainHeight("1")
        bidView.alignAttribute(.Top, toAttribute: .Bottom, ofView: dividerView, predicate: "13")
        bidView.constrainHeight("18")
        bidButton.alignAttribute(.Top, toAttribute: .Bottom, ofView: currentBidLabel, predicate: "13")
        
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
            1 +  // divider
            13 + // padding
            16 + // bid
            13 + // padding
            46 + // bid button
            40   // bottom padding
        
        return imageHeight + CGFloat(remainingHeight)
    }
}

private func heightForImageWithAspectRatio(aspectRatio: CGFloat?) -> CGFloat {
    if let ratio = aspectRatio {
        return CGFloat(MasonryCollectionViewCellWidth) / ratio
    }
    return CGFloat(MasonryCollectionViewCellWidth)
}
