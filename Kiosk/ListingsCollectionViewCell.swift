import Foundation

@objc protocol ListingsCollectionViewCell {
    var saleArtwork: SaleArtwork? { get set }
    var bidWasPressedSignal: RACSignal { get }
}
