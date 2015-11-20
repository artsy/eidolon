import UIKit
import RxSwift

@objc class BidDetails: NSObject {
    typealias DownloadImageClosure = (url: NSURL, imageView: UIImageView) -> ()

    var newUser: NewUser = NewUser()
    var saleArtwork: SaleArtwork?

    var paddleNumber = Variable<String?>(nil)
    var bidderPIN = Variable<String?>(nil)
    var bidAmountCents = Variable<NSNumber?>(nil)
    var bidderID = Variable<String?>(nil)

    var setImage: DownloadImageClosure = { (url, imageView) -> () in
        imageView.sd_setImageWithURL(url)
    }

    init(saleArtwork: SaleArtwork?, paddleNumber: String?, bidderPIN: String?, bidAmountCents: Int?) {
        self.saleArtwork = saleArtwork
        self.paddleNumber.value = paddleNumber
        self.bidderPIN.value = bidderPIN
        self.bidAmountCents.value = bidAmountCents
    }

    /// Not for production use
    convenience init(string: String) {
        self.init(saleArtwork: nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)
    }
}