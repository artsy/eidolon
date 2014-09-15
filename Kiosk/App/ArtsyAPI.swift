import Foundation

// Mark: - API Keys

public struct APIKeys {
    let key: String
    let secret: String
    
    // MARK: Shared Keys
    
    private struct SharedKeys {
        static var instance = APIKeys()
    }

    public static var sharedKeys: APIKeys {
        get {
            return SharedKeys.instance
        }
        
        set (newSharedKeys) {
            SharedKeys.instance = newSharedKeys
        }
    }
    
    // MARK: Methods
    
    public var stubResponses: Bool {
        return countElements(key) == 0 || countElements(secret) == 0
    }
    
    // MARK: Initializers
    
    public init(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }
    
    public init(keys: EidolonKeys) {
        self.init(key: keys.artsyAPIClientKey() ?? "", secret: keys.artsyAPIClientSecret() ?? "")
    }
    
    public init() {
        let keys = EidolonKeys()
        self.init(keys: keys)
    }
}

// MARK: - Provider setup

public struct Provider {
    private static var endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
        let endpoint: Endpoint<ArtsyAPI> = Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)
        // Sign all non-XApp token requests
        switch target {
        case .XApp:
            return endpoint
        default:
            return endpoint.endpointByAddingHTTPHeaderFields(["X-Xapp-Token": XAppToken().token ?? ""])
        }
    }
    
    public static func DefaultProvider() -> ReactiveMoyaProvider<ArtsyAPI> {
        return ReactiveMoyaProvider(endpointsClosure: endpointsClosure, stubResponses: APIKeys.sharedKeys.stubResponses)
    }
    
    public static func StubbingProvider() -> ReactiveMoyaProvider<ArtsyAPI> {
        return ReactiveMoyaProvider(endpointsClosure: endpointsClosure, stubResponses: true)
    }

    private struct SharedProvider {
        static var instance = Provider.DefaultProvider()
    }
    
    public static var sharedProvider: ReactiveMoyaProvider<ArtsyAPI> {
        get {
            return SharedProvider.instance
        }
        
        set (newSharedProvider) {
            SharedProvider.instance = newSharedProvider
        }
    }
}

// MARK: - XApp authentication

/// Request to fetch and store new XApp token if the current token is missing or expired.
private func XAppTokenRequest() -> RACSignal {
    // I don't like an extension of a class referencing what is essentially a singleton of that class.
    var appToken = XAppToken()
    let newTokenSignal = Provider.sharedProvider.request(ArtsyAPI.XApp, parameters: ArtsyAPI.XApp.defaultParameters).filterSuccessfulStatusCodes().mapJSON().doNext({ (response) -> Void in
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
public func XAppRequest(token: ArtsyAPI, method: Moya.Method = Moya.DefaultMethod(), parameters: [String: AnyObject] = Moya.DefaultParameters()) -> RACSignal {
    // First perform XAppTokenRequest(). When it completes, then the signal returned from the closure will be subscribed to.
    return XAppTokenRequest().then({ () -> RACSignal! in
        return Provider.sharedProvider.request(token, method: method, parameters: parameters)
    })
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
            return ["client_id": APIKeys.sharedKeys.key ?? "",
                    "client_secret": APIKeys.sharedKeys.secret ?? ""]
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
