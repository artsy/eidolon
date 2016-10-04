import Foundation
import Artsy_UILabels
import RxSwift
import RxCocoa
import NSObject_Rx

class ListingsCollectionViewCell: UICollectionViewCell {
    typealias DownloadImageClosure = (_ url: URL?, _ imageView: UIImageView) -> ()
    typealias CancelDownloadImageClosure = (_ imageView: UIImageView) -> ()

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
    var reuseBag: DisposeBag?

    lazy var moreInfo: Observable<NSDate> = {
        return [self.imageGestureSigal, self.infoGesture].toObservable().merge()
    }()
    
    fileprivate lazy var imageGestureSigal: Observable<NSDate> = {
        let recognizer = UITapGestureRecognizer()
        self.artworkImageView.addGestureRecognizer(recognizer)
        self.artworkImageView.userInteractionEnabled = true
        return recognizer.rx_event.map { _ in NSDate() }
    }()

    fileprivate lazy var infoGesture: Observable<NSDate> = {
        let recognizer = UITapGestureRecognizer()
        self.moreInfoLabel.addGestureRecognizer(recognizer)
        self.moreInfoLabel.userInteractionEnabled = true
        return recognizer.rx_event.map { _ in NSDate() }
    }()

    fileprivate var _preparingForReuse = PublishSubject<Void>()

    var preparingForReuse: Observable<Void> {
        return _preparingForReuse.asObservable()
    }

    var viewModel = PublishSubject<SaleArtworkViewModel>()
    func setViewModel(_ newViewModel: SaleArtworkViewModel) {
        self.viewModel.onNext(newViewModel)
    }

    fileprivate var _bidPressed = PublishSubject<Date>()
    var bidPressed: Observable<NSDate> {
        return _bidPressed.asObservable()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubscriptions()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubscriptions()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelDownloadImage?(artworkImageView)
        _preparingForReuse.onNext()
        setupSubscriptions()
    }

    func setup() {
        // Necessary to use Autolayout
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupSubscriptions() {

        // Bind subviews
        reuseBag = DisposeBag()

        guard let reuseBag = reuseBag else { return }

        // Start with things not expected to ever change. 
        viewModel.flatMapTo(SaleArtworkViewModel.lotNumber)
            .replaceNilWith("")
            .bindTo(lotNumberLabel.rx_text)
            .addDisposableTo(reuseBag)

        viewModel.map { (viewModel) -> URL? in
                return viewModel.thumbnailURL
            }.subscribeNext { [weak self] url in
                guard let imageView = self?.artworkImageView else { return }
                self?.downloadImage?(url: url, imageView: imageView)
            }.addDisposableTo(reuseBag)

        viewModel.map { $0.artistName ?? "" }
            .bindTo(artistNameLabel.rx_text)
            .addDisposableTo(reuseBag)

        viewModel.map { $0.titleAndDateAttributedString ?? NSAttributedString() }
            .bindTo(artworkTitleLabel.rx_attributedText)
            .addDisposableTo(reuseBag)

        viewModel.map { $0.estimateString }
            .bindTo(estimateLabel.rx_text)
            .addDisposableTo(reuseBag)

        // Now do properties that _do_ change.

        viewModel.flatMap { (viewModel) -> Observable<String> in
                return viewModel.currentBid(prefix: "Current Bid: ", missingPrefix: "Starting Bid: ")
            }
            .bindTo(currentBidLabel.rx_text)
            .addDisposableTo(reuseBag)

        viewModel.flatMapTo(SaleArtworkViewModel.numberOfBids)
            .bindTo(numberOfBidsLabel.rx_text)
            .addDisposableTo(reuseBag)

        viewModel.flatMapTo(SaleArtworkViewModel.forSale)
            .doOnNext { [weak bidButton] forSale in
                // Button titles aren't KVO-able
                bidButton?.setTitle((forSale ? "BID" : "SOLD"), forState: .Normal)
            }
            .bindTo(bidButton.rx_enabled)
            .addDisposableTo(reuseBag)

        bidButton.rx_tap.subscribeNext { [weak self] in
                self?._bidPressed.onNext(Date())
            }
            .addDisposableTo(reuseBag)
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
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }
    
    class func _normalLabel() -> UILabel {
        let label = ARSerifLabel()
        label.font = label.font.withSize(16)
        label.numberOfLines = 1
        return label
    }
    
    class func _sansSerifLabel() -> UILabel {
        let label = ARSansSerifLabel()
        label.font = label.font.withSize(12)
        label.numberOfLines = 1
        return label
    }
    
    class func _italicsLabel() -> UILabel {
        let label = ARItalicsSerifLabel()
        label.font = label.font.withSize(16)
        label.numberOfLines = 1
        return label
    }
    
    class func _largeLabel() -> UILabel {
        let label = _normalLabel()
        label.font = label.font.withSize(20)
        return label
    }
    
    class func _bidButton() -> ActionButton {
        let button = ActionButton()
        button.setTitle("BID", for: UIControlState())
        return button
    }

    class func _boldLabel() -> UILabel {
        let label = _normalLabel()
        label.font = UIFont.serifBoldFont(withSize: label.font.pointSize)
        label.numberOfLines = 1
        return label
    }
    
    class func _infoLabel() -> UILabel {
        let label = ARSansSerifLabelWithChevron()
        label.tintColor = .black()
        label.text = "MORE INFO"
        return label
    }
}
