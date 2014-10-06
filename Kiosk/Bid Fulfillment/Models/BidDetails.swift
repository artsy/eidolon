@objc class BidDetails: NSObject {
    dynamic var newUser: NewUser = NewUser()
    dynamic var saleArtwork: SaleArtwork?

    dynamic var bidderID: String?
    dynamic var bidderPIN: String?
    dynamic  var bidAmountCents: NSNumber?

    init(saleArtwork: SaleArtwork?, bidderID: String?, bidderPIN: String?, bidAmountCents:Int?) {
        self.saleArtwork = saleArtwork
        self.bidderID = bidderID
        self.bidderPIN = bidderPIN
        self.bidAmountCents = bidAmountCents
    }
}