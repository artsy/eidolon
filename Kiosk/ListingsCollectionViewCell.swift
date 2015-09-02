import Foundation
import Artsy_UILabels
import ReactiveCocoa
import Swift_RAC_Macros

class ListingsCollectionViewCell: UICollectionViewCell {
    typealias DownloadImageClosure = (url: NSURL?, imageView: UIImageView) -> ()
    typealias CancelDownloadImageClosure = (imageView: UIImageView) -> ()

    dynamic let lotNumberLabel = ListingsCollectionViewCell._sansSerifLabel()
    dynamic let artworkImageView = ListingsCollectionViewCell._artworkImageView()
    dynamic let artistNameLabel = ListingsCollectionViewCell._largeLabel()
    dynamic let artworkTitleLabel = ListingsCollectionViewCell._italicsLabel()
    dynamic let estimateLabel = ListingsCollectionViewCell._normalLabel()
    dynamic let currentBidLabel = ListingsCollectionViewCell._boldLabel()
    dynamic let numberOfBidsLabel = ListingsCollectionViewCell._rightAlignedNormalLabel()
    dynamic let bidButton = ListingsCollectionViewCell._bidButton()
    dynamic let moreInfoLabel = ListingsCollectionViewCell._infoLabel()

    var downloadImage: DownloadImageClosure?
    var cancelDownloadImage: CancelDownloadImageClosure?

    lazy var moreInfoSignal: RACSignal = {
        // "Jump start" both the more info button signal and the image gesture signal with nil values,
        // then skip the first "jump started" value.
        RACSignal.combineLatest([self.infoGestureSignal.startWith(nil), self.imageGestureSigal.startWith(nil)]).mapReplace(nil).skip(1)
    }()
    
    private lazy var imageGestureSigal: RACSignal = {
        let recognizer = UITapGestureRecognizer()
        self.artworkImageView.addGestureRecognizer(recognizer)
        self.artworkImageView.userInteractionEnabled = true
        return recognizer.rac_gestureSignal()
    }()

    private lazy var infoGestureSignal: RACSignal = {
        let recognizer = UITapGestureRecognizer()
        self.moreInfoLabel.addGestureRecognizer(recognizer)
        self.moreInfoLabel.userInteractionEnabled = true
        return recognizer.rac_gestureSignal()
    }()
    
    dynamic var saleArtwork: SaleArtwork?
    dynamic var bidWasPressedSignal: RACSignal = RACSubject()

    lazy var artworkForSaleSignal: RACSignal = {
        return RACObserve(self, "saleArtwork.forSaleSignal").switchToLatest()
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelDownloadImage?(imageView: artworkImageView)
    }
    
    func setup() {
        // Necessary to use Autolayout
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Bind subviews
        RAC(self, "lotNumberLabel.text") <~ RACObserve(self, "saleArtwork.lotNumberSignal").switchToLatest()

        RACObserve(self, "saleArtwork.artwork").subscribeNext { [weak self] (artwork) -> Void in
            if let imageView = self?.artworkImageView {
                let url = (artwork as? Artwork)?.defaultImage?.thumbnailURL()
                self?.downloadImage?(url: url, imageView: imageView)
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
        
        RAC(self, "currentBidLabel.text") <~ RACObserve(self, "saleArtwork").map({ (saleArtwork) -> AnyObject! in
            return (saleArtwork as? SaleArtwork)?.currentBidSignal(prefix: "Current Bid: ", missingPrefix: "Starting Bid: ") ?? RACSignal.`return`(nil)
        }).switchToLatest().mapNilToEmptyString()
        
        RAC(self, "numberOfBidsLabel.text") <~ RACObserve(self, "saleArtwork").map({ (saleArtwork) -> AnyObject! in
            return (saleArtwork as? SaleArtwork)?.numberOfBidsSignal ?? RACSignal.`return`(nil)
        }).switchToLatest().mapNilToEmptyString()

        RAC(self.bidButton, "enabled") <~ artworkForSaleSignal
        artworkForSaleSignal.subscribeNext { [weak bidButton] (forSale) -> Void in
            let forSale = forSale as! Bool

            let title = forSale ? "BID" : "SOLD"
            bidButton?.setTitle(title, forState: .Normal)
        }
        bidButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self] (_) -> Void in
            (self?.bidWasPressedSignal as! RACSubject).sendNext(nil)
        }
    }
}

private extension ListingsCollectionViewCell {
    
    // Mark: UIView-property-methods – need an _ prefix to appease the compiler ¯\_(ツ)_/¯
    class func _artworkImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .artsyLightGrey()
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
        label.font = label.font.fontWithSize(12)
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
    
    class func _infoLabel() -> UILabel {
        let label = ARSansSerifLabelWithChevron()
        label.tintColor = .blackColor()
        label.text = "MORE INFO"
        return label
    }
}
