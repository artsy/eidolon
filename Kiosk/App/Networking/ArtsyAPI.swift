import Foundation

enum ArtsyAPI {
    case XApp
    case XAuth(email: String, password: String)
    case TrustToken(number: String, auctionPIN: String)

    case SystemTime
    
    case Me
    
    case MyCreditCards
    case CreatePINForBidder(bidderNumber: String)
    case FindBidderRegistration(auctionID: String, phone: String)
    case RegisterToBid(auctionID: String)
    
    case Auctions
    case AuctionListings(id: String)
    case AuctionInfo(auctionID: String)
    case AuctionInfoForArtwork(auctionID: String, artworkID: String)
    case ActiveAuctions
    
    case MyBiddersForAuction(auctionID: String)
    case MyBidPositionsForAuctionArtwork(auctionID: String, artworkID: String)
    case PlaceABid(auctionID: String, artworkID: String, maxBidCents: String)

    case UpdateMe(email: String, phone: String, postCode: String)
    case CreateUser(email: String, password: String, phone: String, postCode: String)

    case RegisterCard(balancedToken: String)

    case LostPINNotification(auctionID: String, number: String)
    case LostPasswordNotification(email: String)
    case FindExistingEmailRegistration(email: String)

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

        case TrustToken(let number, let auctionID):
            return ["number": number, "auction_pin": auctionID]

        case CreateUser(let email,let password,let phone,let postCode):

            return [
                "email": email, "password": password,
                "phone": phone, "location": [ "postal_code": postCode ]
            ]

        case UpdateMe(let email,let phone,let postCode):
            return ["email": email, "phone": phone, "location": [ "postal_code": postCode ]]

        case RegisterCard(let token):
            return ["provider": "balanced", "token": token]

        case FindBidderRegistration(let auctionID, let phone):
            return ["sale_id": auctionID, "number": phone]

        case LostPINNotification(let auctionID, let number):
            return ["sale_id": auctionID, "number": number]

        case LostPasswordNotification(let email):
            return ["email": email]

        case FindExistingEmailRegistration(let email):
            return ["email": email]

        case AuctionListings:
            return ["size": 10]

        case ActiveAuctions:
            return ["is_auction": true, "live": true]

        case MyBidPositionsForAuctionArtwork(let auctionID, let artworkID):
            return ["sale_id": auctionID, "artwork_id": artworkID]


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

        case AuctionInfoForArtwork(let auctionID, let artworkID):
            return "/api/v1/sale/\(auctionID)/sale_artwork/\(artworkID)"

        case SystemTime:
            return "/api/v1/system/time"

        case RegisterToBid:
            return "/api/v1/bidder"

        case MyCreditCards:
            return "/api/v1/me/credit_cards"

        case CreatePINForBidder(let bidderNumber):
            return "/api/v1/bidder/\(bidderNumber)/pin"

        case ActiveAuctions:
            return "/api/v1/sales"

        case Me:
            return "/api/v1/me"

        case UpdateMe:
            return "/api/v1/me"

        case CreateUser:
            return "/api/v1/user"

        case MyBiddersForAuction:
            return "/api/v1/me/bidders"

        case MyBidPositionsForAuctionArtwork:
            return "/api/v1/me/bidder_positions"

        case FindBidderRegistration:
            return "/api/v1/bidder"
            
        case PlaceABid:
            return "/api/v1/me/bidder_position"

        case RegisterCard:
            return "/api/v1/me/credit_cards"

        case TrustToken:
            return "/api/v1/me/trust_token"

        case LostPINNotification:
            return "/api/v1/bidder/pin_notification"

        case LostPasswordNotification:
            return "/api/v1/users/send_reset_password_instructions"

        case FindExistingEmailRegistration:
            return "/api/v1/user"

        }
    }
}

extension ArtsyAPI : MoyaTarget {
    // TODO: - parameterize base URL based on debug, release, etc.

    var base: String { return AppSetup.sharedState.useStaging ? "https://stagingapi.artsy.net" : "https://api.artsy.net" }
    var baseURL: NSURL { return NSURL(string: base)! }

    var sampleData: NSData {
        switch self {

        case XApp:
            return stubbedResponse("XApp")

        case XAuth:
            return stubbedResponse("XAuth")

        case TrustToken:
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

        case UpdateMe:
            return stubbedResponse("Me")

        case CreateUser:
            return stubbedResponse("Me")

            
        // This API returns a 302, so stubbed response isn't valid
        case FindBidderRegistration:
            return stubbedResponse("Me")

        case PlaceABid:
            return stubbedResponse("CreateABid")
            
        case AuctionInfo:
            return stubbedResponse("AuctionInfo")

        case RegisterCard:
            return stubbedResponse("RegisterCard")

        case LostPINNotification:
            return stubbedResponse("RegisterToBid")

        case LostPasswordNotification:
            return stubbedResponse("ForgotPassword")

        case FindExistingEmailRegistration:
            return stubbedResponse("ForgotPassword")

        case AuctionInfoForArtwork:
            return stubbedResponse("AuctionInfoForArtwork")

        case MyBidPositionsForAuctionArtwork:
            return stubbedResponse("MyBidPositionsForAuctionArtwork")
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
            return endpoint.endpointByAddingHTTPHeaderFields(["X-Xapp-Token": XAppToken().token ?? ""])
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
