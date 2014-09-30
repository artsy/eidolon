import UIKit

let MasonryCollectionViewCellWidth: CGFloat = 254

class MasonryCollectionViewCell: UICollectionViewCell {
    let artworkImageView = UIImageView()
    let artistNameLabel = MasonryCollectionViewCell._largeLabel()
    let artworkNameLabel = MasonryCollectionViewCell._italicsLabel()
    let estimateLabel = MasonryCollectionViewCell._italicsLabel()
    let dividerView = MasonryCollectionViewCell._dividerView()
    let currentBidLabel = MasonryCollectionViewCell._bidLabel()
    let numberOfBidsLabel = MasonryCollectionViewCell._rightAlignedNormalLabel()
    let buyNowLabel = MasonryCollectionViewCell._bidLabel()
    let bidButton = MasonryCollectionViewCell._bidButton()
}

extension MasonryCollectionViewCell {
    class func heightForSaleArtwork(saleArtwork: SaleArtwork) -> CGFloat {
        return 500
    }
}

private extension MasonryCollectionViewCell {
    class func _dividerView() -> UIView {
        let dividerView = UIView()
        dividerView.backgroundColor = UIColor.artsyMediumGrey()
        return dividerView
    }
    
    class func _bidLabel() -> UILabel {
        return UILabel()
    }
    
    class func _rightAlignedNormalLabel() -> UILabel {
        return UILabel()
    }
    
    class func _normalLabel() -> UILabel {
        return UILabel()
    }
    
    class func _italicsLabel() -> UILabel {
        return UILabel()
    }
    
    class func _largeLabel() -> UILabel {
        return UILabel()
    }
    
    class func _bidButton() -> ARBlackFlatButton {
        let button = ARBlackFlatButton()
        button.setTitle("BID", forState: .Normal)
        return button
    }
}
