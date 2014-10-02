@objc class BidDetails: NSObject {
    dynamic var newUser: NewUser?

    dynamic var bidderID: String?
    dynamic var bidderPIN: String?
    dynamic  var bidAmountCents: NSNumber?

    init(newUser: NewUser?, bidderID: String?, bidderPIN: String?, bidAmountCents:Int?) {
        self.newUser = newUser
        self.bidderID = bidderID
        self.bidderPIN = bidderPIN
        self.bidAmountCents = bidAmountCents
    }
}