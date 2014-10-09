import UIKit

class FulfillmentNavigationController: UINavigationController {
    var bidDetails = BidDetails(saleArtwork:nil, bidderID: nil, bidderPIN: nil, bidAmountCents:nil)
    lazy var auctionID:String? = self.bidDetails.saleArtwork?.auctionID

    var loggedInProvider:ReactiveMoyaProvider<ArtsyAPI>?

    func updateUserCredentials() -> RACSignal? {
        let endpoint: ArtsyAPI = ArtsyAPI.Me
        let request = loggedInProvider?.request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(User.self)

        request?.subscribeNext({ [weak self] (user) -> Void in
            let newUser = self!.bidDetails.newUser
            let user = user as User
            
            newUser.email = user.email
            newUser.password = "----"
            newUser.phoneNumber = user.phoneNumber
            newUser.zipCode = user.postalCode
            
        }, error: { [weak self] (error) -> Void in
                println("error, the pin is likely wrong")
                return
        })
        
        return request?
    }

}
