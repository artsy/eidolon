import Foundation

enum ArtsyAPI {
    case XApp
    case XAuth(email: String, password: String)
    case Auctions
    case AuctionListings(id: String)
    case SystemTime

    var defaultParameters: [String: AnyObject] {
        switch self {

        case .XAuth(let email, let password):
            return [
                "client_id": APIKeys.sharedKeys.key ?? "",
                "client_secret": APIKeys.sharedKeys.secret ?? "",
                "email": email,
                "password":  password,
                "grant_type": "credentials"
            ]

        case .XApp:
            return ["client_id": APIKeys.sharedKeys.key ?? "",
                    "client_secret": APIKeys.sharedKeys.secret ?? ""]

        case .Auctions:
            return ["is_auction": "true"]

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

        case Auctions:
            return "/api/v1/sales"

        case AuctionListings(let id):
            return "/api/v1/sale/\(id)/sale_artworks"

        case SystemTime:
            return "api/v1/system/time"

        }
    }
}

extension ArtsyAPI : MoyaTarget {
    // TODO: - parameterize base URL based on debug, release, etc.
     var baseURL: NSURL { return NSURL(string: "https://stagingapi.artsy.net")! }
     var sampleData: NSData {
        switch self {

        case .XApp:
            return stubbedResponse("XApp")

        case .XAuth:
            return stubbedResponse("XApp")

        case .Auctions:
            return stubbedResponse("Auctions")

        case .AuctionListings(let id):
            return stubbedResponse("AuctionListings")
            
        case SystemTime:
            return stubbedResponse("SystemTime")
            
        }
    }
}

// MARK: - Provider setup

 struct Provider {
    private static var endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
        let endpoint: Endpoint<ArtsyAPI> = Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)
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

//     static func AuthenticatedProvider(credentials:UserCredentials) -> AuthenticatedMoyaProvider<ArtsyAPI> {
//        // DI the stub?!
//        return AuthenticatedMoyaProvider(credentials:credentials, stubResponses: false)
//    }

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
