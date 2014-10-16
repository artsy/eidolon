@objc class BidDetails: NSObject {
    dynamic var newUser: NewUser = NewUser()
    dynamic var saleArtwork: SaleArtwork?

    dynamic var bidderNumber: String?
    dynamic var bidderPIN: String?
    dynamic var bidAmountCents: NSNumber?
    dynamic var bidderID: String?

    init(saleArtwork: SaleArtwork?, bidderNumber: String?, bidderPIN: String?, bidAmountCents:Int?) {
        self.saleArtwork = saleArtwork
        self.bidderNumber = bidderNumber
        self.bidderPIN = bidderPIN
        self.bidAmountCents = bidAmountCents
    }
}