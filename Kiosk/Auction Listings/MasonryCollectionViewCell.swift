import UIKit

let MasonryCollectionViewCellWidth: CGFloat = 254

class MasonryCollectionViewCell: UICollectionViewCell, ListingsCollectionViewCell {
    private dynamic let artworkImageView = MasonryCollectionViewCell._artworkImageView()
    private dynamic let artistNameLabel = MasonryCollectionViewCell._largeLabel()
    private dynamic let artworkNameLabel = MasonryCollectionViewCell._italicsLabel()
    private dynamic let estimateLabel = MasonryCollectionViewCell._italicsLabel()
    private dynamic let dividerView: UIView = MasonryCollectionViewCell._dividerView()
    private dynamic let currentBidLabel = MasonryCollectionViewCell._bidLabel()
    private dynamic let numberOfBidsLabel = MasonryCollectionViewCell._rightAlignedNormalLabel()
    private dynamic let buyNowLabel = MasonryCollectionViewCell._bidLabel()
    private dynamic let bidButton = MasonryCollectionViewCell._bidButton()
    private lazy var cellSubviews: [UIView] = [self.artworkImageView, self.artistNameLabel, self.artworkNameLabel, self.estimateLabel, self.dividerView, self.currentBidLabel, self.numberOfBidsLabel, self.buyNowLabel, self.bidButton]
    private lazy var cellWidthSubviews: [UIView] = [self.artworkImageView, self.artistNameLabel, self.artworkNameLabel, self.estimateLabel, self.dividerView, self.buyNowLabel, self.bidButton]
    
    private var artworkImageViewHeightConstraint: NSLayoutConstraint?
    
    internal dynamic var saleArtwork: SaleArtwork?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        super.applyLayoutAttributes(layoutAttributes)
        
        if let artworkImageViewHeightConstraint = artworkImageViewHeightConstraint {
            contentView.removeConstraint(artworkImageViewHeightConstraint)
        }
        // TODO: Get actual height
        artworkImageViewHeightConstraint = artworkImageView.constrainHeight("200").first as? NSLayoutConstraint
        setNeedsLayout()
    }
}

extension MasonryCollectionViewCell {
    class func heightForSaleArtwork(saleArtwork: SaleArtwork) -> CGFloat {
        return 500
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
        artistNameLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: artworkImageView, predicate: "40")
        artistNameLabel.constrainHeight("40")
        artworkNameLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: artistNameLabel, predicate: "0")
        artworkNameLabel.constrainHeight("32")
        estimateLabel.alignAttribute(.Top, toAttribute: .Bottom, ofView: artworkNameLabel, predicate: "0")
        estimateLabel.constrainHeight("32")
        //TODO: Rest of the views
        
        // Bind subviews
        RAC(self, "artistNameLabel.text") <~ RACObserve(self, "saleArtwork.artwork").map({ (artwork) -> AnyObject! in
            //TODO Figure out what to do for defaults and generalize
            if artwork == nil {
                return "nil"
            } else {
                return "not nil"
            }
        })
    }
    
    // MARK: UIView-property-methods – need an _ prefix to appease the compiler ¯\_(ツ)_/¯
    class func _artworkImageView() -> UIView {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.orangeColor()
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
