import UIKit
import Moya
import ReactiveCocoa

public class FulfillmentNavigationController: UINavigationController {

    /// The the collection of details necessary to eventually create a bid
    public var bidDetails = BidDetails(saleArtwork:nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents:nil)
    public var auctionID:String!
    public var user:User!

    /// Otherwise we're fine with a legit auth token
    var xAccessToken: String? {
        didSet(oldToken) {

            let newEndpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
                var endpoint: Endpoint<ArtsyAPI> = Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)

                return endpoint.endpointByAddingHTTPHeaderFields(["X-Access-Token": self.xAccessToken!])
            }
            loggedInProvider = ReactiveMoyaProvider(endpointsClosure: newEndpointsClosure, endpointResolver: endpointResolver(), stubResponses: APIKeys.sharedKeys.stubResponses)
        }
    }

    var loggedInProvider: ReactiveMoyaProvider<ArtsyAPI>?

    func reset() {
        loggedInProvider = nil
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie as NSHTTPCookie)
        }
    }

    func updateUserCredentials() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.Me
        let request = loggedInProvider!.request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(User.self)

        return request.doNext { [weak self] (fullUser) -> Void in
            let newUser = self?.bidDetails.newUser
            self?.user = fullUser as? User
            
            newUser?.email = self?.user?.email
            newUser?.password = "----"
            newUser?.phoneNumber = self?.user?.phoneNumber
            newUser?.zipCode = self?.user?.location?.postalCode
            newUser?.name = self?.user?.name

        } .doError { [weak self] (error) -> Void in
            logger.log("error, the authentication for admin is likely wrong")
            return
        }
    }
}
