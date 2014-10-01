import UIKit

let MasonryCollectionViewCellWidth: CGFloat = 254

class MasonryCollectionViewCell: UICollectionViewCell, ListingsCollectionViewCell {
    private dynamic let artworkImageView = MasonryCollectionViewCell._artworkImageView()
    private dynamic let artistNameLabel = MasonryCollectionViewCell._largeLabel()
    private dynamic let artworkTitleLabel = MasonryCollectionViewCell._italicsLabel()
    private dynamic let estimateLabel = MasonryCollectionViewCell._italicsLabel()
    private dynamic let dividerView: UIView = MasonryCollectionViewCell._dividerView()
    private dynamic let currentBidLabel = MasonryCollectionViewCell._bidLabel()
    private dynamic let numberOfBidsLabel = MasonryCollectionViewCell._rightAlignedNormalLabel()
    private dynamic let bidButton = MasonryCollectionViewCell._bidButton()
    
    private lazy var cellSubviews: [UIView] = [self.artworkImageView, self.artistNameLabel, self.artworkTitleLabel, self.estimateLabel, self.dividerView, self.currentBidLabel, self.numberOfBidsLabel, self.bidButton]
    private lazy var cellWidthSubviews: [UIView] = [self.artworkImageView, self.artistNameLabel, self.artworkTitleLabel, self.estimateLabel, self.dividerView, self.bidButton]
    
    private var artworkImageViewHeightConstraint: NSLayoutConstraint?
    
    internal dynamic var saleArtwork: SaleArtwork? {
        didSet {
            if let artworkImageViewHeightConstraint = artworkImageViewHeightConstraint {
                artworkImageView.removeConstraint(artworkImageViewHeightConstraint)
            }
            let imageHeight = heightForImageWithSize(saleArtwork?.artwork.images?.first?.imageSize)
            artworkImageViewHeightConstraint = artworkImageView.constrainHeight("\(imageHeight)").first as? NSLayoutConstraint
            layoutIfNeeded()
        }
    }
    
    internal let bidWasPressedSignal: RACSignal = RACSubject()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForReuse() {
        artworkImageView.sd_cancelCurrentImageLoad()
    }
}

extension MasonryCollectionViewCell {
    class func heightForSaleArtwork(saleArtwork: SaleArtwork) -> CGFloat {
        let imageHeight = heightForImageWithSize(saleArtwork.artwork.images?.first?.imageSize)
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

private extension MasonryCollectionViewCell {
    
    // Mark: convenience setup methods
    
    func setup() {
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
        // TODO: Divider should be dotted
        dividerView.alignAttribute(.Top, toAttribute: .Bottom, ofView: estimateLabel, predicate: "13")
        dividerView.constrainHeight("1")
        currentBidLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: dividerView, predicate: "13")
        currentBidLabel.constrainHeight("16")
        bidButton.alignAttribute(.Top, toAttribute: .Bottom, ofView: currentBidLabel, predicate: "13")
        
        // Bind subviews
        RACObserve(self, "saleArtwork.artwork").subscribeNext { [unowned self] (artwork) -> Void in
            if let url = (artwork as? Artwork)?.images?.first?.thumbnailURL() {
                self.artworkImageView.sd_setImageWithURL(url)
            } else {
                self.artworkImageView.image = nil
            }
        }
        RAC(self, "artistNameLabel.text") <~ RACObserve(self, "saleArtwork.artwork").map({ (artwork) -> AnyObject! in
            return (artwork as? Artwork)?.artists?.first?.name
        }).mapNilToEmptyString()
        RAC(self, "artworkTitleLabel.text") <~ RACObserve(self, "saleArtwork.artwork").map({ (artwork) -> AnyObject! in
            return (artwork as? Artwork)?.title
        }).mapNilToEmptyString()
        RAC(self, "estimateLabel.text") <~ RACObserve(self, "saleArtwork").map({ (saleArtwork) -> AnyObject! in
            return (saleArtwork as? SaleArtwork)?.estimateString
        }).mapNilToEmptyString()
        RAC(self, "currentBidLabel.text") <~ RACObserve(self, "saleArtwork").map({ (saleArtwork) -> AnyObject! in
            if let currentBidCents = (saleArtwork as? SaleArtwork)?.highestBidCents {
                return "Current bid: $\(currentBidCents)"
            } else {
                return "No bids"
            }
        }).mapNilToEmptyString()
        bidButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [unowned self] (_) -> Void in
            (self.bidWasPressedSignal as RACSubject).sendNext(nil)
        }
    }
    
    // Mark: UIView-property-methods – need an _ prefix to appease the compiler ¯\_(ツ)_/¯
    class func _artworkImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.artsyLightGrey()
        return imageView
    }
    
    class func _dividerView() -> UIView {
        let dividerView = UIView()
        dividerView.backgroundColor = UIColor.artsyMediumGrey()
        return dividerView
    }
    
    class func _font() -> UIFont {
        return UIFont.serifFontWithSize(16)
    }
    
    class func _boldFont() -> UIFont {
        return UIFont.serifBoldFontWithSize(16)
    }
    
    class func _bidLabel() -> UILabel {
        let label = _normalLabel()
        label.font = _boldFont()
        return label
    }
    
    class func _rightAlignedNormalLabel() -> UILabel {
        let label = _normalLabel()
        label.textAlignment = .Right
        return label
    }
    
    class func _normalLabel() -> UILabel {
        let label = ARSerifLabel()
        label.font = _font()
        return label
    }
    
    class func _italicsLabel() -> UILabel {
        let label = ARItalicsSerifLabel()
        label.font = _font()
        return label
    }
    
    class func _largeLabel() -> UILabel {
        let label = _normalLabel()
        label.font = label.font.fontWithSize(20)
        return label
    }
    
    class func _bidButton() -> ARBlackFlatButton {
        let button = ARBlackFlatButton()
        button.setTitle("BID", forState: .Normal)
        return button
    }
}

private extension RACSignal {
    func mapNilToEmptyString() -> RACSignal {
        return map { (string) -> AnyObject! in
            if let string = string as? String {
                return string
            } else {
                return ""
            }
        }
    }
}

private func heightForImageWithSize(size: CGSize?) -> CGFloat {
    let defaultSize = CGSize(width: MasonryCollectionViewCellWidth, height: MasonryCollectionViewCellWidth)
    return heightForImageWithSize(size ?? defaultSize)
}

private func heightForImageWithSize(size: CGSize) -> CGFloat {
    let aspectRatio = size.width / size.height
    if aspectRatio > 1 {
        return CGFloat(MasonryCollectionViewCellWidth) * aspectRatio
    } else {
        return CGFloat(MasonryCollectionViewCellWidth) / aspectRatio
    }
}
