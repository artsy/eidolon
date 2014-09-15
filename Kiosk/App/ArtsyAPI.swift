import Foundation

struct APIKeys {
    let key: String
    let secret: String
    
    var stubResponses: Bool {
        return countElements(key) > 0 && countElements(secret) > 0
    }
    
    init() {
        let keys = EidolonKeys()
        key = keys.artsy_api_client() ?? ""
        secret = keys.artsy_api_client_secret() ?? ""
    }
}

private let keys = APIKeys()
private var appToken = XAppToken()

// MARK: - Provider setup

let endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
    let endpoint: Endpoint<ArtsyAPI> = Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)
    // Sign all non-XApp token requests
    switch target {
    case .XApp:
        return endpoint
    default:
        return endpoint.endpointByAddingHTTPHeaderFields(["X-Xapp-Token": appToken.token ?? ""])
    }
}

let ArtsyProvider = ReactiveMoyaProvider(endpointsClosure: endpointsClosure, stubResponses: keys.stubResponses)

// MARK: - Provider Extensions

public extension ReactiveMoyaProvider {
    
    /// Request to fetch and store new XApp token if the current token is missing or expired.
    private func XAppTokenRequest() -> RACSignal {
        // I don't like an extension of a class referencing what is essentially a singleton of that class.
        let newTokenSignal = ArtsyProvider.request(ArtsyAPI.XApp, parameters: ArtsyAPI.XApp.defaultParameters).filterSuccessfulStatusCodes().mapJSON().doNext({ (response) -> Void in
            if let dictionary = response as? NSDictionary {
                let formatter = ISO8601DateFormatter()
                appToken.token = dictionary["xapp_token"] as String?
                appToken.expiry = formatter.dateFromString(dictionary["expires_in"] as String?)
            }
        }).logError().ignoreValues()
        
        // Signal that returns whether our current token is valid
        let validTokenSignal = RACSignal.`return`(appToken.isValid)
        
        // If the token is valid, just return an empty signal, otherwise return a signal that fetches new tokens
        return RACSignal.`if`(validTokenSignal, then: RACSignal.empty(), `else`: newTokenSignal)
    }
    
    /// Request to fetch a given target. Ensures that valid XApp tokens exist before making request
    public func XAppRequest(token: T, method: Moya.Method = Moya.DefaultMethod(), parameters: [String: AnyObject] = Moya.DefaultParameters()) -> RACSignal {
        // First perform XAppTokenRequest(). When it completes, then the signal returned from the closure will be subscribed to.
        return XAppTokenRequest().then({ () -> RACSignal! in
            return self.request(token, method: method, parameters: parameters)
        })
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

public enum ArtsyAPI {
    case XApp
    case FeaturedWorks
    
    public var defaultParameters: [String: AnyObject] {
        switch self {
        case .XApp:
            return ["client_id": keys.key ?? "",
                    "client_secret": keys.secret ?? ""]
        case .FeaturedWorks:
            return ["key": "homepage:featured-artworks",
                    "sort": "key",
                    "mobile": "true",
                    "published": "true"]
        default:
            return [:]
        }
    }
}

extension ArtsyAPI : MoyaPath {
    public var path: String {
        switch self {
        case .XApp:
            return "/api/v1/xapp_token"
        case .FeaturedWorks:
            return "/api/v1/sets"
        }
    }
}

extension ArtsyAPI : MoyaTarget {
    // TODO: - parameterize base URL based on debug, release, etc. 
    public var baseURL: NSURL { return NSURL(string: "https://stagingapi.artsy.net") }
    public var sampleData: NSData {
        switch self {
        case .XApp:
            return stubbedResponse("XApp")
        case .FeaturedWorks:
            return stubbedResponse("FeaturedWorks")
        }
    }
}

public func url(route: MoyaTarget) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString!
}
