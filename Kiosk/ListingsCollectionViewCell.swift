import Foundation

class ListingsCollectionViewCell: UICollectionViewCell {
    dynamic let artworkImageView = MasonryCollectionViewCell._artworkImageView()
    dynamic let artistNameLabel = MasonryCollectionViewCell._largeLabel()
    dynamic let artworkTitleLabel = MasonryCollectionViewCell._italicsLabel()
    dynamic let estimateLabel = MasonryCollectionViewCell._normalLabel()
    dynamic let dividerView: UIView = MasonryCollectionViewCell._dividerView()
    dynamic let currentBidLabel = MasonryCollectionViewCell._boldLabel()
    dynamic let numberOfBidsLabel = MasonryCollectionViewCell._rightAlignedNormalLabel()
    dynamic let bidButton = MasonryCollectionViewCell._bidButton()
    
    dynamic var saleArtwork: SaleArtwork?
    dynamic var bidWasPressedSignal: RACSignal = RACSubject()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artworkImageView.sd_cancelCurrentImageLoad()
    }
    
    func setup() {
        // Necessary to use Autolayout
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // Bind subviews
        RACObserve(self, "saleArtwork.artwork").subscribeNext { [weak self] (artwork) -> Void in
            if let url = (artwork as? Artwork)?.images?.first?.thumbnailURL() {
                self?.artworkImageView.sd_setImageWithURL(url)
            } else {
                self?.artworkImageView.image = nil
            }
        }
        
        RAC(self, "artistNameLabel.text") <~ RACObserve(self, "saleArtwork.artwork").map({ (artwork) -> AnyObject! in
            return (artwork as? Artwork)?.artists?.first?.name
        }).mapNilToEmptyString()
        
        RAC(self, "artworkTitleLabel.attributedText") <~ RACObserve(self, "saleArtwork.artwork").map({ (artwork) -> AnyObject! in
            if let artwork = artwork as? Artwork {
                return artwork.titleAndDate
            } else {
                return nil
            }
        }).mapNilToEmptyAttributedString()
        
        RAC(self, "estimateLabel.text") <~ RACObserve(self, "saleArtwork").map({ (saleArtwork) -> AnyObject! in
            return (saleArtwork as? SaleArtwork)?.estimateString
        }).mapNilToEmptyString()
        
        RAC(self, "currentBidLabel.text") <~ RACObserve(self, "saleArtwork").map({ (saleArtwork) -> AnyObject! in
            if let currentBidCents = (saleArtwork as? SaleArtwork)?.highestBidCents {
                return "Current bid: \(NSNumberFormatter.currencyStringForCents(currentBidCents))"
            } else {
                return "No bids"
            }
        }).mapNilToEmptyString()
        
        RAC(self, "numberOfBidsLabel.text") <~ RACObserve(self, "saleArtwork").map({ (saleArtwork) -> AnyObject! in
            return (saleArtwork as? SaleArtwork)?.bidCount
        }).map({ (optionalBidCount) -> AnyObject! in
            // Technically, the bidCount is Int?, but the `as?` cast could fail (it never will, but the compiler doesn't know that)
            // So we need to unwrap it as an optional optional. Yo dawg.
            let bidCount = optionalBidCount as Int?

            if let bidCount = bidCount {
                let suffix = bidCount == 1 ? "" : "s"
                return "\(bidCount) bid\(suffix) placed"
            } else {
                return "0 bids placed"
            }
        })
        
        bidButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self] (_) -> Void in
            (self?.bidWasPressedSignal as RACSubject).sendNext(nil)
        }
    }
}

private extension MasonryCollectionViewCell {
    
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
    
    class func _rightAlignedNormalLabel() -> UILabel {
        let label = _normalLabel()
        label.textAlignment = .Right
        return label
    }
    
    class func _normalLabel() -> UILabel {
        let label = ARSerifLabel()
        label.font = label.font.fontWithSize(16)
        return label
    }
    
    class func _sansSerifLabel() -> UILabel {
        let label = ARSansSerifLabel()
        label.font = label.font.fontWithSize(14)
        return label
    }
    
    class func _italicsLabel() -> UILabel {
        let label = ARItalicsSerifLabel()
        label.font = label.font.fontWithSize(16)
        return label
    }
    
    class func _largeLabel() -> UILabel {
        let label = _normalLabel()
        label.font = label.font.fontWithSize(20)
        return label
    }
    
    class func _bidButton() -> ActionButton {
        let button = ActionButton()
        button.setTitle("BID", forState: .Normal)
        return button
    }

    class func _boldLabel() -> UILabel {
        let label = _normalLabel()
        label.font = UIFont.serifBoldFontWithSize(label.font.pointSize)
        return label
    }
}
