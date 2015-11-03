import UIKit
import Moya
import ReactiveCocoa

// We abstract this out so that we don't have network models, etc, aware of the view controller.
// This is a "source of truth" that should be referenced in lieu of many independent variables. 
protocol FulfillmentController: class {
    var bidDetails: BidDetails { get set }
    var auctionID: String! { get set }
    var xAccessToken: String? { get set }
    var loggedInProvider: ReactiveCocoaMoyaProvider<ArtsyAPI>? { get }
    var loggedInOrDefaultProvider: ReactiveCocoaMoyaProvider<ArtsyAPI> { get }
}

class FulfillmentNavigationController: UINavigationController, FulfillmentController {

    // MARK: - FulfillmentController bits

    /// The the collection of details necessary to eventually create a bid
    var bidDetails = BidDetails(saleArtwork:nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents:nil)
    var auctionID: String!
    var user: User!

    /// Otherwise we're fine with a legit auth token
    var xAccessToken: String? {
        didSet(oldToken) {
            guard let accessToken = self.xAccessToken else { return }

            let newEndpointsClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
                // Grab existing endpoint to piggy-back off of any existing configurations being used by the sharedprovider.
                let endpoint = Provider.sharedProvider.endpointClosure(target)

                return endpoint.endpointByAddingHTTPHeaderFields(["X-Access-Token": accessToken])
            }

            loggedInProvider = ReactiveCocoaMoyaProvider(endpointClosure: newEndpointsClosure, requestClosure: endpointResolver(), stubClosure: Provider.APIKeysBasedStubBehaviour, plugins: Provider.plugins)
        }
    }

    var loggedInProvider: ReactiveCocoaMoyaProvider<ArtsyAPI>?

    var loggedInOrDefaultProvider: ReactiveCocoaMoyaProvider<ArtsyAPI> {
        if let loggedInProvider = loggedInProvider {
            return loggedInProvider
        }

        return Provider.sharedProvider
    }

    // MARK: - Everything else

    func reset() {
        loggedInProvider = nil
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = storage.cookies
        cookies?.forEach { storage.deleteCookie($0) }
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

