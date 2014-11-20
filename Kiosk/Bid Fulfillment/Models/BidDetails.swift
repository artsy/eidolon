@objc public class BidDetails: NSObject {
    public dynamic var newUser: NewUser = NewUser()
    public dynamic var saleArtwork: SaleArtwork?

    public dynamic var paddleNumber: String?
    public dynamic var bidderPIN: String?
    public dynamic var bidAmountCents: NSNumber?
    public dynamic var bidderID: String?

    public init(saleArtwork: SaleArtwork?, paddleNumber: String?, bidderPIN: String?, bidAmountCents:Int?) {
        self.saleArtwork = saleArtwork
        self.paddleNumber = paddleNumber
        self.bidderPIN = bidderPIN
        self.bidAmountCents = bidAmountCents
    }

    /// Not for production use
    public convenience init(string: String) {
        self.init(saleArtwork: nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents: nil)
    }
}