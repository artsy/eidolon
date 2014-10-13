import Foundation

enum ArtsyAPI {
    case XApp
    case XAuth(email: String, password: String)
    case SystemTime
    
    case Me
    
    case MyCreditCards
    case CreatePINForBidder(bidderID: String)
    case FindBidderRegistration(auctionID: String, phone: String)
    case RegisterToBid(auctionID: String)
    
    case Auctions
    case AuctionListings(id: String)
    case AuctionInfo(auctionID: String)
    case ActiveAuctions
    
    case MyBiddersForAuction(auctionID: String)
    case PlaceABid(auctionID: String, artworkID: String, maxBidCents: String)

    case UpdateMe(email: String, phone: String, postCode: String)
    case CreateUser(email: String, password: String, phone: String, postCode: String)
//    case RegisterCard(balancedToken: String)
    
    var defaultParameters: [String: AnyObject] {
        switch self {

        case XAuth(let email, let password):
            return [
                "client_id": APIKeys.sharedKeys.key ?? "",
                "client_secret": APIKeys.sharedKeys.secret ?? "",
                "email": email,
                "password":  password,
                "grant_type": "credentials"
            ]

        case XApp:
            return ["client_id": APIKeys.sharedKeys.key ?? "",
                    "client_secret": APIKeys.sharedKeys.secret ?? ""]

        case Auctions:
            return ["is_auction": "true"]

        case RegisterToBid(let auctionID):
            return ["sale_id": auctionID]

        case MyBiddersForAuction(let auctionID):
            return ["sale_id": auctionID]

        case PlaceABid(let auctionID, let artworkID, let maxBidCents):
            return [
                "sale_id": auctionID,
                "artwork_id":  artworkID,
                "max_bid_amount_cents": maxBidCents
            ]
            
        default:
            return [:]
        }
    }
}

extension ArtsyAPI : MoyaPath {
     var path: String {
        switch self {

        case .XApp:
            return "/api/v1/xapp_token"

        case .XAuth:
            return "/oauth2/access_token"

        case AuctionInfo(let id):
            return "/api/v1/sale/\(id)"
            
        case Auctions:
            return "/api/v1/sales"

        case AuctionListings(let id):
            return "/api/v1/sale/\(id)/sale_artworks"

        case SystemTime:
            return "/api/v1/system/time"

        case RegisterToBid:
            return "/api/v1/bidder"

        case MyCreditCards:
            return "/api/v1/me/credit_cards"

        case CreatePINForBidder(let bidderID):
            return "/api/v1/bidder/\(bidderID)/auction_pin"

        case ActiveAuctions:
            return "/api/v1/sales?is_auction=true&live=true"

        case Me:
            return "/api/v1/me"

        case UpdateMe:
            return "/api/v1/me"

        case CreateUser:
            return "/api/v1/user"

        case MyBiddersForAuction:
            return "/api/v1/me/bidders"

        case FindBidderRegistration:
            return "/api/v1/bidder"
            
        case PlaceABid:
            return "/api/v1/me/bidder_position"
        }
    }
}

extension ArtsyAPI : MoyaTarget {
    // TODO: - parameterize base URL based on debug, release, etc.
     var baseURL: NSURL { return NSURL(string: "https://stagingapi.artsy.net")! }
     var sampleData: NSData {
        switch self {

        case XApp:
            return stubbedResponse("XApp")

        case XAuth:
            return stubbedResponse("XAuth")

        case Auctions:
            return stubbedResponse("Auctions")

        case AuctionListings:
            return stubbedResponse("AuctionListings")
            
        case SystemTime:
            return stubbedResponse("SystemTime")

        case CreatePINForBidder:
            return stubbedResponse("CreatePINForBidder")

        case ActiveAuctions:
            return stubbedResponse("ActiveAuctions")

        case MyCreditCards:
            return stubbedResponse("MyCreditCards")

        case RegisterToBid:
            return stubbedResponse("RegisterToBid")

        case MyBiddersForAuction:
            return stubbedResponse("MyBiddersForAuction")

        case Me:
            return stubbedResponse("Me")

        case .UpdateMe:
            return stubbedResponse("Me")
            
        case .CreateUser:
            return stubbedResponse("Me")

            
        // This API returns a 302, so stubbed response isn't valid
        case FindBidderRegistration:
            return stubbedResponse("Me")

        case PlaceABid:
            return stubbedResponse("CreateABid")
            
        case .AuctionInfo:
            return stubbedResponse("AuctionInfo")
            
        }
    }
}

// MARK: - Provider setup

 struct Provider {
    private static var endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
        
        var endpoint: Endpoint<ArtsyAPI> = Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)
        // Sign all non-XApp token requests
        switch target {
        case .XApp:
            return endpoint
        case .XAuth:
            return endpoint
        default:
            endpoint = endpoint.endpointByAddingHTTPHeaderFields(["X-Xapp-Token": XAppToken().token ?? ""])
        }
        
        // target-specific parameters
        switch target {
        case .FindBidderRegistration(let auctionID, let phone):
            return endpoint.endpointByAddingParameters(["sale_id": auctionID, "phone": phone])
        default:
            return endpoint
        }
        
        
    }
    
     static func DefaultProvider() -> ReactiveMoyaProvider<ArtsyAPI> {
        return ReactiveMoyaProvider(endpointsClosure: endpointsClosure, stubResponses: APIKeys.sharedKeys.stubResponses)
    }
    
     static func StubbingProvider() -> ReactiveMoyaProvider<ArtsyAPI> {
        return ReactiveMoyaProvider(endpointsClosure: endpointsClosure, stubResponses: true)
    }

    private struct SharedProvider {
        static var instance = Provider.DefaultProvider()
    }
    
     static var sharedProvider: ReactiveMoyaProvider<ArtsyAPI> {
        get {
            return SharedProvider.instance
        }
        
        set (newSharedProvider) {
            SharedProvider.instance = newSharedProvider
        }
    }
}


// MARK: - Provider support

private func stubbedResponse(filename: String) -> NSData! {
    @objc class TestClass { }
    
    let bundle = NSBundle(forClass: TestClass.self)
    let path = bundle.pathForResource(filename, ofType: "json")
    return NSData(contentsOfFile: path!)
}

private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}

 func url(route: MoyaTarget) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString!
}
