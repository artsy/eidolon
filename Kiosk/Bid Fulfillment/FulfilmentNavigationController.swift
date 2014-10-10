import UIKit

class FulfillmentNavigationController: UINavigationController {

    /// The the collection of details necessary to eventually create a bid
    var bidDetails = BidDetails(saleArtwork:nil, bidderID: nil, bidderPIN: nil, bidAmountCents:nil)

    lazy var auctionID:String? = self.bidDetails.saleArtwork?.auctionID

    var user:User?
    
    var loggedInProvider:ReactiveMoyaProvider<ArtsyAPI>?

    func updateUserCredentials() -> RACSignal? {
        let endpoint: ArtsyAPI = ArtsyAPI.Me
        let request = loggedInProvider?.request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(User.self)

        request?.subscribeNext({ [weak self] (fullUser) -> Void in
            let newUser = self!.bidDetails.newUser
            
            self?.user = fullUser as? User
            
            newUser.email = self?.user?.email
            newUser.password = "----"
            newUser.phoneNumber = self?.user?.phoneNumber
            newUser.zipCode = self?.user?.postalCode
            
        }, error: { [weak self] (error) -> Void in
                println("error, the pin is likely wrong")
                return
        })

        return request?
    }
}
