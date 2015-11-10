import Foundation
import Artsy_UILabels
import RxSwift

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

    lazy var viewModelSignal: RACSignal = {
        return RACObserve(self, "viewModel").ignore(nil)
    }()
    
    dynamic var viewModel: SaleArtworkViewModel!
    dynamic var bidWasPressedSignal: RACSignal = RACSubject()

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

        // Start with things not expected to ever change. 

        RAC(self, "lotNumberLabel.text") <~ viewModelSignal.map { (viewModel) -> AnyObject! in
            return (viewModel as! SaleArtworkViewModel).lotNumberSignal
        }.switchToLatest()

        viewModelSignal.subscribeNext { [weak self] (viewModel) -> Void in
            if let imageView = self?.artworkImageView {
                let url = (viewModel as? SaleArtworkViewModel)?.thumbnailURL
                self?.downloadImage?(url: url, imageView: imageView)
            }
        }
        
        RAC(self, "artistNameLabel.text") <~ viewModelSignal.map({ (viewModel) -> AnyObject! in
            return (viewModel as! SaleArtworkViewModel).artistName
        }).mapNilToEmptyString()
        
        RAC(self, "artworkTitleLabel.attributedText") <~ viewModelSignal.map({ (viewModel) -> AnyObject! in
            return (viewModel as! SaleArtworkViewModel).titleAndDateAttributedString
        }).mapNilToEmptyAttributedString()
        
        RAC(self, "estimateLabel.text") <~ viewModelSignal.map({ (viewModel) -> AnyObject! in
            return (viewModel as! SaleArtworkViewModel).estimateString
        }).mapNilToEmptyString()

        // Now do properties that _do_ change.

        RAC(self, "currentBidLabel.text") <~ viewModelSignal.map({ (viewModel) -> AnyObject! in
            return (viewModel as! SaleArtworkViewModel).currentBidSignal(prefix: "Current Bid: ", missingPrefix: "Starting Bid: ")
        }).switchToLatest().mapNilToEmptyString()
        
        RAC(self, "numberOfBidsLabel.text") <~ viewModelSignal.map { (viewModel) -> AnyObject! in
            return (viewModel as! SaleArtworkViewModel).numberOfBidsSignal
        }.switchToLatest().mapNilToEmptyString()

        RAC(self.bidButton, "enabled") <~ viewModelSignal.map { (viewModel) -> AnyObject! in
            return (viewModel as! SaleArtworkViewModel).forSaleSignal
        }.switchToLatest().doNext { [weak bidButton] (forSale) -> Void in
            // Button titles aren't KVO-able
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
