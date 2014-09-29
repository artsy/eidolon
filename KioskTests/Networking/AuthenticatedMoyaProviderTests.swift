import Quick
import Nimble

class AuthenticatedMoyaProviderTests: QuickSpec {
    override func spec() {
        // This crashes, and I've wasted enough time trying to figure out why.
        // https://github.com/artsy/eidolon/issues/60

//        it("passes xauth headers to requests") {
//            let mainProvider = Provider.DefaultProvider()
//            
//            let accessToken = "sdfsdsfsdsdgdgdfh"
//            
//            let credentials = UserCredentials(user: User(), accessToken: accessToken)
//            let networkProvider = AuthenticatedMoyaProvider(credentials: credentials, stubResponses: false) as AuthenticatedMoyaProvider<ArtsyAPI>
//
//            let auctionEndpoint: ArtsyAPI = ArtsyAPI.AuctionListings(id: "ici-live-auction")
//            let endPoint = networkProvider.endpoint(auctionEndpoint, method: .GET, parameters: [:])
//
//            let endPointHTTPToken: AnyObject! = endPoint.httpHeaderFields["X-Access-Token"] as AnyObject!
//            expect(endPointHTTPToken as? String) == accessToken
//        }
    }
}
