import Foundation
import Artsy_UILabels
import RxSwift
import RxOptional
import RxCocoa
import NSObject_Rx

class ListingsCollectionViewCell: UICollectionViewCell {
    typealias DownloadImageClosure = (_ url: URL?, _ imageView: UIImageView) -> ()
    typealias CancelDownloadImageClosure = (_ imageView: UIImageView) -> ()

    @objc dynamic let lotNumberLabel = ListingsCollectionViewCell._sansSerifLabel()
    @objc dynamic let artworkImageView = ListingsCollectionViewCell._artworkImageView()
    @objc dynamic let artistNameLabel = ListingsCollectionViewCell._largeLabel()
    @objc dynamic let artworkTitleLabel = ListingsCollectionViewCell._italicsLabel()
    @objc dynamic let estimateLabel = ListingsCollectionViewCell._normalLabel()
    @objc dynamic let currentBidLabel = ListingsCollectionViewCell._boldLabel()
    @objc dynamic let numberOfBidsLabel = ListingsCollectionViewCell._rightAlignedNormalLabel()
    @objc dynamic let bidButton = ListingsCollectionViewCell._bidButton()
    @objc dynamic let moreInfoLabel = ListingsCollectionViewCell._infoLabel()

    var downloadImage: DownloadImageClosure?
    var cancelDownloadImage: CancelDownloadImageClosure?
    var reuseBag: DisposeBag?

    lazy var moreInfo: Observable<Date> = {
        return Observable.from([self.imageGestureSigal, self.infoGesture]).merge()
    }()
    
    fileprivate lazy var imageGestureSigal: Observable<Date> = {
        let recognizer = UITapGestureRecognizer()
        self.artworkImageView.addGestureRecognizer(recognizer)
        self.artworkImageView.isUserInteractionEnabled = true
        return recognizer.rx.event.map { _ in Date() }
    }()

    fileprivate lazy var infoGesture: Observable<Date> = {
        let recognizer = UITapGestureRecognizer()
        self.moreInfoLabel.addGestureRecognizer(recognizer)
        self.moreInfoLabel.isUserInteractionEnabled = true
        return recognizer.rx.event.map { _ in Date() }
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
    var bidPressed: Observable<Date> {
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
        _preparingForReuse.onNext(Void())
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
        viewModel.flatMapTo(SaleArtworkViewModel.lotLabel)
            .replaceNilWith("")
            .mapToOptional()
            .bind(to: lotNumberLabel.rx.text)
            .disposed(by: reuseBag)

        viewModel.map { (viewModel) -> URL? in
                return viewModel.thumbnailURL
            }.subscribe(onNext: { [weak self] url in
                guard let imageView = self?.artworkImageView else { return }
                self?.downloadImage?(url, imageView)
            }).disposed(by: reuseBag)

        viewModel.map { $0.artistName ?? "" }
            .bind(to: artistNameLabel.rx.text)
            .disposed(by: reuseBag)

        viewModel.map { $0.titleAndDateAttributedString }
            .mapToOptional()
            .bind(to: artworkTitleLabel.rx.attributedText)
            .disposed(by: reuseBag)

        viewModel.map { $0.estimateString }
            .bind(to: estimateLabel.rx.text)
            .disposed(by: reuseBag)

        // Now do properties that _do_ change.

        viewModel.flatMap { (viewModel) -> Observable<String> in
                return viewModel.currentBid(prefix: "Current Bid: ", missingPrefix: "Starting Bid: ")
            }
            .mapToOptional()
            .bind(to: currentBidLabel.rx.text)
            .disposed(by: reuseBag)

        viewModel.flatMapTo(SaleArtworkViewModel.numberOfBids)
            .mapToOptional()
            .bind(to: numberOfBidsLabel.rx.text)
            .disposed(by: reuseBag)

        viewModel.flatMapTo(SaleArtworkViewModel.forSale)
            .map { forSale  in (forSale ? "BID" : "SOLD") }
            .bind(to: bidButton.rx.title())
            .disposed(by: reuseBag)

        viewModel.flatMapTo(SaleArtworkViewModel.forSale)
            .bind(to: bidButton.rx.isEnabled)
            .disposed(by: reuseBag)

        bidButton.rx.tap.subscribe(onNext: { [weak self] in
                self?._bidPressed.onNext(Date())
            })
            .disposed(by: reuseBag)
    }
}

private extension ListingsCollectionViewCell {
    
    // Mark: UIView-property-methods – need an _ prefix to appease the compiler ¯\_(ツ)_/¯
    class func _artworkImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .artsyGrayLight()
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
        button.setTitle("BID", for: .normal)
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
        label.tintColor = .black
        label.text = "MORE INFO"
        return label
    }
}
