import UIKit
import RxSwift
import ORStackView

let MasonryCollectionViewCellWidth: CGFloat = 254

class MasonryCollectionViewCell: ListingsCollectionViewCell {
    private lazy var bidView: UIView = {
        let view = UIView()
        for subview in [self.currentBidLabel, self.numberOfBidsLabel] {
            view.addSubview(subview)
            subview.alignTopEdgeWithView(view, predicate:"13")
            subview.alignBottomEdgeWithView(view, predicate:"0")
            subview.constrainHeight("18")
        }
        self.currentBidLabel.alignLeadingEdgeWithView(view, predicate: "0")
        self.numberOfBidsLabel.alignTrailingEdgeWithView(view, predicate: "0")
        return view
    }()
    
    private lazy var cellSubviews: [UIView] = [self.stackView]

    private var artworkImageViewHeightConstraint: NSLayoutConstraint?

    private let stackView = ORTagBasedAutoStackView()
    
    override func setup() {
        super.setup()
        
        contentView.constrainWidth("\(MasonryCollectionViewCellWidth)")
        contentView.addSubview(stackView)
        stackView.alignToView(contentView)

        let whitespaceGobbler = WhitespaceGobbler()

        let stackViewSubviews = [artworkImageView, lotNumberLabel, artistNameLabel, artworkTitleLabel, estimateLabel, bidView, bidButton, moreInfoLabel, whitespaceGobbler]
        for (index, subview) in stackViewSubviews.enumerate() {
            subview.tag = index
        }

        stackView.addSubview(artworkImageView, withTopMargin: "0", sideMargin: "0")
        stackView.addSubview(lotNumberLabel, withTopMargin: "20", sideMargin: "0")
        stackView.addSubview(artistNameLabel, withTopMargin: "20", sideMargin: "0")
        stackView.addSubview(artworkTitleLabel, withTopMargin: "10", sideMargin: "0")
        stackView.addSubview(estimateLabel, withTopMargin: "10", sideMargin: "0")
        stackView.addSubview(bidView, withTopMargin: "13", sideMargin: "0")
        stackView.addSubview(bidButton, withTopMargin: "13", sideMargin: "0")
        stackView.addSubview(moreInfoLabel, withTopMargin: "0", sideMargin: "0")
        stackView.addSubview(whitespaceGobbler, withTopMargin: "0", sideMargin: "0")

        artistNameLabel.constrainHeight("20")
        artworkTitleLabel.constrainHeight("16")
        estimateLabel.constrainHeight("16")

        moreInfoLabel.constrainHeight("44")

        viewModel.flatMapTo(SaleArtworkViewModel.lotNumber)
            .map { $0.isNilOrEmpty }
            .subscribeNext(removeLabelWhenEmpty(lotNumberLabel, topMargin: "20"))
            .addDisposableTo(rx_disposeBag)

        viewModel
            .map { $0.estimateString }
            .map { $0.isEmpty }
            .subscribeNext(removeLabelWhenEmpty(estimateLabel, topMargin: "10"))
            .addDisposableTo(rx_disposeBag)

        viewModel
            .map { $0.artistName }
            .map { $0.isNilOrEmpty }
            .subscribeNext(removeLabelWhenEmpty(artistNameLabel, topMargin: "20"))
            .addDisposableTo(rx_disposeBag)

        // Binds the imageView to always be the correct aspect ratio
        viewModel.subscribeNext { [weak self] viewModel in
                if let artworkImageViewHeightConstraint = self?.artworkImageViewHeightConstraint {
                    self?.artworkImageView.removeConstraint(artworkImageViewHeightConstraint)
                }
                let imageHeight = heightForImageWithAspectRatio(viewModel.thumbnailAspectRatio)
                self?.artworkImageViewHeightConstraint = self?.artworkImageView.constrainHeight("\(imageHeight)").first as? NSLayoutConstraint
                self?.layoutIfNeeded()
            }
            .addDisposableTo(rx_disposeBag)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bidView.drawTopDottedBorderWithColor(.artsyMediumGrey())
    }

    func removeLabelWhenEmpty(label: UIView, topMargin: String) -> (Bool) -> Void {
        return { [weak self] isEmpty in
            guard let `self` = self else { return }
            if isEmpty {
                self.stackView.removeSubview(label)
            } else {
                self.stackView.addSubview(label, withTopMargin: topMargin, sideMargin: "0")
            }
        }
    }
}

extension MasonryCollectionViewCell {
    class func heightForCellWithImageAspectRatio(aspectRatio: CGFloat?, hasEstimate: Bool) -> CGFloat {
        let imageHeight = heightForImageWithAspectRatio(aspectRatio)
        let estimateHeight =
            16 + // estimate
            13   // padding
        let remainingHeight =
            20 + // padding
            20 + // artist name
            10 + // padding
            16 + // artwork name
            10 + // padding
            13 + // padding
            16 + // bid
            13 + // padding
            44 + // more info button
            12   // padding
        
        return imageHeight + ButtonHeight + CGFloat(remainingHeight) + CGFloat(hasEstimate ? estimateHeight : 0)
    }
}

private func heightForImageWithAspectRatio(aspectRatio: CGFloat?) -> CGFloat {
    if let ratio = aspectRatio {
        if ratio != 0 {
            return CGFloat(MasonryCollectionViewCellWidth) / ratio
        }
    }
    return CGFloat(MasonryCollectionViewCellWidth)
}
