import Foundation
import Artsy_UILabels
import RxSwift
import RxCocoa
import NSObject_Rx

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

    lazy var moreInfoSignal: Observable<NSDate> = {
        // TODO: Skip 1 or anything?
        return [self.imageGestureSigal, self.infoGestureSignal].toObservable().merge()
    }()
    
    private lazy var imageGestureSigal: Observable<NSDate> = {
        let recognizer = UITapGestureRecognizer()
        self.artworkImageView.addGestureRecognizer(recognizer)
        self.artworkImageView.userInteractionEnabled = true
        return recognizer.rx_event.map { _ in NSDate() }
    }()

    private lazy var infoGestureSignal: Observable<NSDate> = {
        let recognizer = UITapGestureRecognizer()
        self.moreInfoLabel.addGestureRecognizer(recognizer)
        self.moreInfoLabel.userInteractionEnabled = true
        return recognizer.rx_event.map { _ in NSDate() }
    }()

    private var _preparingForReuse = PublishSubject<Void>()

    var preparingForReuse: Observable<Void> {
        return _preparingForReuse.asObservable()
    }
    
    var viewModel = PublishSubject<SaleArtworkViewModel>()
    var _bidPressed = PublishSubject<NSDate>() // TODO: Private?
    var bidPressed: Observable<NSDate> {
        return _bidPressed.skip(1).asObservable()
    }

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
        _preparingForReuse.onNext()
    }
    
    func setup() {
        // Necessary to use Autolayout
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Bind subviews

        // Start with things not expected to ever change. 
        viewModel.flatMap(SaleArtworkViewModel.lotNumberSignal)
            .replaceNilWith("")
            .bindTo(lotNumberLabel.rx_text)
            .addDisposableTo(rx_disposeBag)

        viewModel.map { (viewModel) -> NSURL? in
                return viewModel.thumbnailURL
            }.subscribeNext { [weak self] url in
                guard let imageView = self?.artworkImageView else { return }
                self?.downloadImage?(url: url, imageView: imageView)
            }.addDisposableTo(rx_disposeBag)

        viewModel.map { $0.artistName ?? "" }
            .bindTo(artistNameLabel.rx_text)
            .addDisposableTo(rx_disposeBag)

        viewModel.map { $0.titleAndDateAttributedString ?? NSAttributedString() }
            .bindTo(artworkTitleLabel.rx_attributedText)
            .addDisposableTo(rx_disposeBag)

        viewModel.map { $0.estimateString }
            .bindTo(estimateLabel.rx_text)
            .addDisposableTo(rx_disposeBag)

        // Now do properties that _do_ change.

        viewModel.flatMap { (viewModel) -> Observable<String> in
                return viewModel.currentBidSignal(prefix: "Current Bid: ", missingPrefix: "Starting Bid: ")
            }
            .bindTo(currentBidLabel.rx_text)
            .addDisposableTo(rx_disposeBag)

        viewModel.flatMap(SaleArtworkViewModel.numberOfBidsSignal)
            .bindTo(numberOfBidsLabel.rx_text)
            .addDisposableTo(rx_disposeBag)

        viewModel.flatMap(SaleArtworkViewModel.forSaleSignal)
            .subscribeNext { [weak bidButton] forSale in
                // Button titles aren't KVO-able
                bidButton?.setTitle((forSale ? "BID" : "SOLD"), forState: .Normal)
            }
            .addDisposableTo(rx_disposeBag)

        bidButton.rx_tap.subscribeNext { [weak self] in
                self?._bidPressed.onNext(NSDate())
            }
            .addDisposableTo(rx_disposeBag)
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
