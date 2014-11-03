@objc class BidDetails: NSObject {
    dynamic var newUser: NewUser = NewUser()
    dynamic var saleArtwork: SaleArtwork?

    dynamic var paddleNumber: String?
    dynamic var bidderPIN: String?
    dynamic var bidAmountCents: NSNumber?
    dynamic var bidderID: String?

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