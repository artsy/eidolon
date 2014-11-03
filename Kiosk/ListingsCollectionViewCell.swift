import Foundation

class ListingsCollectionViewCell: UICollectionViewCell {
    dynamic let artworkImageView = ListingsCollectionViewCell._artworkImageView()
    dynamic let artistNameLabel = ListingsCollectionViewCell._largeLabel()
    dynamic let artworkTitleLabel = ListingsCollectionViewCell._italicsLabel()
    dynamic let estimateLabel = ListingsCollectionViewCell._normalLabel()
    dynamic let currentBidLabel = ListingsCollectionViewCell._boldLabel()
    dynamic let numberOfBidsLabel = ListingsCollectionViewCell._rightAlignedNormalLabel()
    dynamic let bidButton = ListingsCollectionViewCell._bidButton()
    dynamic let moreInfoButton = ListingsCollectionViewCell._infoButton()
    
    lazy var moreInfoSignal: RACSignal = {
        // "Jump start" both the more info button signal and the image gesture signal with nil values,
        // then skip the first "jump started" value.
        RACSignal.combineLatest([self.moreInfoButton.rac_signalForControlEvents(.TouchUpInside).startWith(nil), self.imageGestureSigal.startWith(nil)]).mapReplace(nil).skip(1)
    }()
    
    private lazy var imageGestureSigal: RACSignal = {
        let recognizer = UITapGestureRecognizer()
        self.artworkImageView.addGestureRecognizer(recognizer)
        return recognizer.rac_gestureSignal()
    }()
    
    dynamic var saleArtwork: SaleArtwork?
    dynamic var bidWasPressedSignal: RACSignal = RACSubject()

    var enableBidButtonSignal: RACSignal? {
        // Creates a write-once property as RAC doesnt not allow having two binded 
        // observers to the same place
        didSet(oldSignal) {
            if (oldSignal == nil) {
                RAC(self.bidButton, "enabled") <~ enableBidButtonSignal!
            }
        }
    }

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
        
        RAC(self, "estimateLabel.text") <~ RACObserve(self, "saleArtwork.estimateString").mapNilToEmptyString()
        
        RAC(self, "currentBidLabel.text") <~ RACObserve(self, "saleArtwork.highestBidCents").map({ (highestBidCents) -> AnyObject! in
            if let currentBidCents = highestBidCents as? Int {
                return "Current bid: \(NSNumberFormatter.currencyStringForCents(currentBidCents))"
            } else {
                return "No bids"
            }
        }).mapNilToEmptyString()
        
        RAC(self, "numberOfBidsLabel.text") <~ RACObserve(self, "saleArtwork.bidCount").map({ (optionalBidCount) -> AnyObject! in
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

private extension ListingsCollectionViewCell {
    
    // Mark: UIView-property-methods – need an _ prefix to appease the compiler ¯\_(ツ)_/¯
    class func _artworkImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.userInteractionEnabled = true
        imageView.backgroundColor = UIColor.artsyLightGrey()
        return imageView
    }

    class func _rightAlignedNormalLabel() -> UILabel {
        let label = _normalLabel()
        label.textAlignment = .Right
        label.numberOfLines = 1
        return label
    }
    
    class func _normalLabel() -> UILabel {
        let label = ARSerifLabel()
        label.font = label.font.fontWithSize(16)
        label.numberOfLines = 1
        return label
    }
    
    class func _sansSerifLabel() -> UILabel {
        let label = ARSansSerifLabel()
        label.font = label.font.fontWithSize(14)
        label.numberOfLines = 1
        return label
    }
    
    class func _italicsLabel() -> UILabel {
        let label = ARItalicsSerifLabel()
        label.font = label.font.fontWithSize(16)
        label.numberOfLines = 1
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
        label.numberOfLines = 1
        return label
    }
    
    class func _infoButton() -> UIButton {
        let button = ARUppercaseButton()
        button.setTitle("More Info >", forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.sansSerifFontWithSize(13)
        button.contentHorizontalAlignment = .Left
        return button
    }
}
