import UIKit

class TableCollectionViewCell: UICollectionViewCell, ListingsCollectionViewCell {
    internal dynamic var saleArtwork: SaleArtwork?
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        backgroundColor = UIColor.blackColor()
    }
}
