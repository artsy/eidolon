import UIKit

let MasonryCollectionViewCellWidth: CGFloat = 254

class MasonryCollectionViewCell: ListingsCollectionViewCell {
    fileprivate lazy var bidView: UIView = {
        let view = UIView()
        for subview in [self.currentBidLabel, self.numberOfBidsLabel] {
            view.addSubview(subview)
            subview.alignTopEdge(with: view, predicate:"13")
            subview.alignBottomEdge(with: view, predicate:"0")
            subview.constrainHeight("18")
        }
        self.currentBidLabel.alignLeadingEdge(with: view, predicate: "0")
        self.numberOfBidsLabel.alignTrailingEdge(with: view, predicate: "0")
        return view
    }()
    
    fileprivate lazy var cellSubviews: [UIView] = [self.artworkImageView, self.lotNumberLabel, self.artistNameLabel, self.artworkTitleLabel, self.estimateLabel, self.bidView, self.bidButton, self.moreInfoLabel]

    fileprivate var artworkImageViewHeightConstraint: NSLayoutConstraint?
    
    override func setup() {
        super.setup()
        
        contentView.constrainWidth("\(MasonryCollectionViewCellWidth)")
        
        // Add subviews
        for subview in cellSubviews {
            self.contentView.addSubview(subview)
            subview.alignLeading("0", trailing: "0", to: self.contentView)
        }
        
        // Constrain subviews
        artworkImageView.alignTop("0", bottom: nil, to: contentView)
        let lotNumberTopConstraint = lotNumberLabel.alignAttribute(.top, to: .bottom, of: artworkImageView, predicate: "20").first as! NSLayoutConstraint
        let artistNameTopConstraint = artistNameLabel.alignAttribute(.top, to: .bottom, of: lotNumberLabel, predicate: "10").first as! NSLayoutConstraint
        artistNameLabel.constrainHeight("20")
        artworkTitleLabel.alignAttribute(.top, to: .bottom, of: artistNameLabel, predicate: "10")
        artworkTitleLabel.constrainHeight("16")
        estimateLabel.alignAttribute(.top, to: .bottom, of: artworkTitleLabel, predicate: "10")
        estimateLabel.constrainHeight("16")
        bidView.alignAttribute(.top, to: .bottom, of: estimateLabel, predicate: "13")
        bidButton.alignAttribute(.top, to: .bottom, of: currentBidLabel, predicate: "13")
        moreInfoLabel.alignAttribute(.top, to: .bottom, of: bidButton, predicate: "0")
        moreInfoLabel.constrainHeight("44")
        moreInfoLabel.alignAttribute(.bottom, to: .bottom, of: contentView, predicate: "12")

        viewModel.flatMapTo(SaleArtworkViewModel.lotNumber)
            .subscribeNext { (lotNumber)in
                switch lotNumber {
                case .some(let text) where text.isEmpty:
                    fallthrough
                case .none:
                    lotNumberTopConstraint.constant = 0
                    artistNameTopConstraint.constant = 20
                default:
                    lotNumberTopConstraint.constant = 20
                    artistNameTopConstraint.constant = 10
                }
            }
            .addDisposableTo(rx_disposeBag)

        // Bind subviews

        viewModel.subscribeNext { [weak self] viewModel in
                if let artworkImageViewHeightConstraint = self?.artworkImageViewHeightConstraint {
                    self?.artworkImageView.removeConstraint(artworkImageViewHeightConstraint)
                }
                let imageHeight = heightForImage(withAspectRatio: viewModel.thumbnailAspectRatio)
                self?.artworkImageViewHeightConstraint = self?.artworkImageView.constrainHeight("\(imageHeight)").first as? NSLayoutConstraint
                self?.layoutIfNeeded()
            }
            .addDisposableTo(rx_disposeBag)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bidView.drawTopDottedBorder(with: .artsyGrayMedium())
    }
}

extension MasonryCollectionViewCell {
    class func heightForCellWithImageAspectRatio(_ aspectRatio: CGFloat?) -> CGFloat {
        let imageHeight = heightForImage(withAspectRatio: aspectRatio)
        let remainingHeight =
            20 + // padding
            20 + // artist name
            10 + // padding
            16 + // artwork name
            10 + // padding
            16 + // estimate
            13 + // padding
            13 + // padding
            16 + // bid
            13 + // padding
            44 + // more info button
            12   // padding
        
        return imageHeight + ButtonHeight + CGFloat(remainingHeight)
    }
}

private func heightForImage(withAspectRatio aspectRatio: CGFloat?) -> CGFloat {
    if let ratio = aspectRatio {
        if ratio != 0 {
            return CGFloat(MasonryCollectionViewCellWidth) / ratio
        }
    }
    return CGFloat(MasonryCollectionViewCellWidth)
}
