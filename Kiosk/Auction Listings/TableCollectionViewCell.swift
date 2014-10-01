import UIKit

class TableCollectionViewCell: UICollectionViewCell, ListingsCollectionViewCell {
    internal dynamic var saleArtwork: SaleArtwork?
    internal let bidWasPressedSignal: RACSignal = RACSubject()
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        backgroundColor = UIColor.blackColor()
    }
}
