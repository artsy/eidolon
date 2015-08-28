import UIKit

@objc class BidDetails: NSObject {
    typealias DownloadImageClosure = (url: NSURL, imageView: UIImageView) -> ()

    dynamic var newUser: NewUser = NewUser()
    dynamic var saleArtwork: SaleArtwork?

    dynamic var paddleNumber: String?
    dynamic var bidderPIN: String?
    dynamic var bidAmountCents: NSNumber?
    dynamic var bidderID: String?

    var setImage: DownloadImageClosure = { (url, imageView) -> () in
        imageView.sd_setImageWithURL(url)
    }

    init(saleArtwork: SaleArtwork?, paddleNumber: String?, bidderPIN: String?, bidAmountCents:Int?) {
        self.saleArtwork = saleArtwork
        self.paddleNumber = paddleNumber
        self.bidderPIN = bidderPIN
        self.bidAmountCents = bidAmountCents
    }

    /// Not for production use
    convenience init(string: String) {
        self.init(saleArtwork: nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)
    }
}