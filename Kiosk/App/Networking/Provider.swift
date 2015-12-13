import Foundation
import ISO8601DateFormatter
import Moya
import RxSwift
import Alamofire

class OnlineProvider<Target where Target: MoyaTarget>: RxMoyaProvider<Target> {

    let online: Observable<Bool>

    init(endpointClosure: MoyaProvider<Target>.EndpointClosure = MoyaProvider.DefaultEndpointMapping,
        requestClosure: MoyaProvider<Target>.RequestClosure = MoyaProvider.DefaultRequestMapping,
        stubClosure: MoyaProvider<Target>.StubClosure = MoyaProvider.NeverStub,
        manager: Manager = Alamofire.Manager.sharedInstance,
        plugins: [Plugin<Target>] = [],
        online: Observable<Bool> = connectedToInternetOrStubbing()) {

            self.online = online
            super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: plugins)
    }
}

enum Provider {
    case Default(provider: OnlineProvider<ArtsyAPI>)
    case Authorized(provider: OnlineProvider<ArtsyAPI>, xAccessToken: String)

    init(provider: OnlineProvider<ArtsyAPI>) {
        self = .Default(provider: provider)
    }

    init(provider: OnlineProvider<ArtsyAPI>, xAccessToken: String) {
        self = .Authorized(provider: provider, xAccessToken: xAccessToken)
    }
}

private extension Provider {
    var provider: OnlineProvider<ArtsyAPI> {
        switch self {
        case .Default(let provider):
            return provider
        case .Authorized(let provider, _):
            return provider
        }
    }
}

private extension Provider {

    /// Request to fetch and store new XApp token if the current token is missing or expired.
    func XAppTokenRequest(defaults: NSUserDefaults) -> Observable<String?> {

        var appToken = XAppToken(defaults: defaults)

        // If we have a valid token, return it and forgo a request for a fresh one.
        if appToken.isValid {
            return just(appToken.token)
        }

        let newTokenRequest = self.provider.request(ArtsyAPI.XApp)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map { element -> (token: String?, expiry: String?) in
                guard let dictionary = element as? NSDictionary else { return (token: nil, expiry: nil) }

                return (token: dictionary["xapp_token"] as? String, expiry: dictionary["expires_in"] as? String)
            }
            .doOn { event in
                guard case Event.Next(let element) = event else { return }

                let formatter = ISO8601DateFormatter()
                appToken.token = element.0
                appToken.expiry = formatter.dateFromString(element.1)
            }
            .map { (token, expiry) -> String? in
                return token
            }
            .logError()

        return newTokenRequest
    }
}

// "Public" interface
extension Provider {

    /// Request to fetch a given target. Ensures that valid XApp tokens exist before making request
    func request(token: ArtsyAPI, defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) -> Observable<MoyaResponse> {

        if case .Default = self where token.requiresAuthorization {
            return failWith(EidolonError.NotLoggedIn)
        }

        return provider.online
            .ignore(false)  // Wait unti we're online
            .take(1)        // Take 1 to make sure we only invoke the API once.
            .flatMap { _ -> Observable<MoyaResponse> in // Turn the online state into a network request
                let actualRequest = self.provider.request(token)
                return self.XAppTokenRequest(defaults).flatMap { _ in actualRequest }
        }
    }
}

// Static methods
extension Provider {

    static func DefaultProvider() -> Provider {
        return Provider(provider: OnlineProvider(endpointClosure: endpointsClosure,
            requestClosure: Provider.endpointResolver(),
            stubClosure: APIKeysBasedStubBehaviour,
            plugins: Provider.plugins))
    }

    static func AuthorizedProvider(xAccessToken: String) -> Provider {
        return Provider(provider: OnlineProvider(endpointClosure: endpointsClosure,
            requestClosure: Provider.endpointResolver(),
            stubClosure: APIKeysBasedStubBehaviour,
            plugins: Provider.plugins), xAccessToken: xAccessToken)
    }

    static func StubbingProvider() -> Provider {
        return Provider(provider: OnlineProvider(endpointClosure: endpointsClosure, requestClosure: Provider.endpointResolver(), stubClosure: MoyaProvider.ImmediatelyStub, online: just(true)))
    }

    static var endpointsClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in
        var endpoint: Endpoint<ArtsyAPI> = Endpoint<ArtsyAPI>(URL: url(target), sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
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

    static func APIKeysBasedStubBehaviour(_: ArtsyAPI) -> Moya.StubBehavior {
        return APIKeys.sharedKeys.stubResponses ? .Immediate : .Never
    }

    static var plugins: [Plugin<ArtsyAPI>] {
        return [NetworkLogger<ArtsyAPI>(whitelist: { (target: ArtsyAPI) -> Bool in
            switch target {
            case .MyBidPosition: return true
            default: return false
            }
            }, blacklist: { target -> Bool in
                switch target {
                case .Ping: return true
                default: return false
                }
        })]
    }

    // (Endpoint<Target>, NSURLRequest -> Void) -> Void
    static func endpointResolver() -> MoyaProvider<ArtsyAPI>.RequestClosure {
        return { (endpoint, closure) in
            let request: NSMutableURLRequest = endpoint.urlRequest.mutableCopy() as! NSMutableURLRequest
            request.HTTPShouldHandleCookies = false
            closure(request)
        }
    }
}
