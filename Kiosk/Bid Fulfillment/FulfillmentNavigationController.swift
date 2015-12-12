import UIKit
import Moya
import RxSwift

// We abstract this out so that we don't have network models, etc, aware of the view controller.
// This is a "source of truth" that should be referenced in lieu of many independent variables. 
protocol FulfillmentController: class {
    var bidDetails: BidDetails { get set }
    var auctionID: String! { get set }
}

class FulfillmentNavigationController: UINavigationController, FulfillmentController {

    // MARK: - FulfillmentController bits

    /// The the collection of details necessary to eventually create a bid
    var bidDetails = BidDetails(saleArtwork:nil, paddleNumber: nil, bidderPIN: nil, bidAmountCents:nil)
    var auctionID: String!
    var user: User!

    var provider: Provider!

//    /// Otherwise we're fine with a legit auth token
//    var xAccessToken: String? {
//        didSet(oldToken) {
//            guard let accessToken = self.xAccessToken else { return }
//
//            let newEndpointsClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
//                // Grab existing endpoint to piggy-back off of any existing configurations being used by the sharedprovider.
//                let endpoint = Provider.sharedProvider.endpointClosure(target)
//
//                return endpoint.endpointByAddingHTTPHeaderFields(["X-Access-Token": accessToken])
//            }
//
//            loggedInProvider = RxMoyaProvider(endpointClosure: newEndpointsClosure, requestClosure: endpointResolver(), stubClosure: Provider.APIKeysBasedStubBehaviour, plugins: Provider.plugins)
//        }
//    }
//
//    var loggedInProvider: RxMoyaProvider<ArtsyAPI>?
//
//    var loggedInOrDefaultProvider: RxMoyaProvider<ArtsyAPI> {
//        if let loggedInProvider = loggedInProvider {
//            return loggedInProvider
//        }
//
//        return Provider.sharedProvider
//    }

    // MARK: - Everything else

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // TODO: Review to make sure this works. 

        if let destination = segue.destinationViewController as? PlaceBidViewController {
            destination.provider = provider
        }
    }

    func reset() {
//        loggedInProvider = nil
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = storage.cookies
        cookies?.forEach { storage.deleteCookie($0) }
    }

    func updateUserCredentials(loggedInProvider: Provider) -> Observable<Void> {
        let endpoint: ArtsyAPI = ArtsyAPI.Me
        let request = loggedInProvider.request(endpoint).filterSuccessfulStatusCodes().mapJSON().mapToObject(User)

        return request
            .doOnNext { [weak self] fullUser in
                guard let me = self else { return }

                me.user = fullUser

                let newUser = me.bidDetails.newUser

                newUser.email.value = me.user.email
                newUser.password.value = "----"
                newUser.phoneNumber.value = me.user.phoneNumber
                newUser.zipCode.value = me.user.location?.postalCode
                newUser.name.value = me.user.name
            }
            .logError("error, the authentication for admin is likely wrong: ")
            .map(void)
    }
}

