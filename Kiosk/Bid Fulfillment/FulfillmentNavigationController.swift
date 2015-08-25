import UIKit
import Moya
import ReactiveCocoa

// We abstract this out so that we don't have network models, etc, aware of the view controller.
// This is a "source of truth" that should be referenced in lieu of many independent variables. 
public protocol FulfillmentController {
    var bidDetails: BidDetails { get set }
    var auctionID: String! { get set }
    var xAccessToken: String? { get set }
    var loggedInProvider: ReactiveCocoaMoyaProvider<ArtsyAPI>? { get }
    var loggedInOrDefaultProvider: ReactiveCocoaMoyaProvider<ArtsyAPI> { get }
}

public class FulfillmentNavigationController: UINavigationController, FulfillmentController {

    // MARK: - FulfillmentController bits

    /// The the collection of details necessary to eventually create a bid
    public var bidDetails = BidDetails(saleArtwork:nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents:nil)
    public var auctionID: String!
    public var user: User!

    /// Otherwise we're fine with a legit auth token
    public var xAccessToken: String? {
        didSet(oldToken) {

            let newEndpointsClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
                let endpoint: Endpoint<ArtsyAPI> = Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, {target.sampleData}), method: target.method, parameters: target.parameters)

                return endpoint.endpointByAddingHTTPHeaderFields(["X-Access-Token": self.xAccessToken!])
            }
            loggedInProvider = ReactiveCocoaMoyaProvider(endpointClosure: newEndpointsClosure, endpointResolver: endpointResolver(), stubBehavior: Provider.APIKeysBasedStubBehaviour)
        }
    }

    public var loggedInProvider: ReactiveCocoaMoyaProvider<ArtsyAPI>?

    public var loggedInOrDefaultProvider: ReactiveCocoaMoyaProvider<ArtsyAPI> {
        if let loggedInProvider = loggedInProvider {
            return loggedInProvider
        }

        return Provider.sharedProvider
    }

    // MARK: - Everything else

    func reset() {
        loggedInProvider = nil
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie )
        }
    }

    func updateUserCredentials() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.Me
        let request = loggedInProvider!.request(endpoint).filterSuccessfulStatusCodes().mapJSON().mapToObject(User.self)

        return request.doNext { [weak self] (fullUser) -> Void in
            let newUser = self?.bidDetails.newUser
            self?.user = fullUser as? User
            
            newUser?.email = self?.user?.email
            newUser?.password = "----"
            newUser?.phoneNumber = self?.user?.phoneNumber
            newUser?.zipCode = self?.user?.location?.postalCode
            newUser?.name = self?.user?.name

        } .doError { (error) -> Void in
            logger.log("error, the authentication for admin is likely wrong")
            return
        }
    }
}
