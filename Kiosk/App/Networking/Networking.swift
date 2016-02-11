import Foundation
import ISO8601DateFormatter
import Moya
import RxSwift
import Alamofire

class OnlineProvider<Target where Target: TargetType>: RxMoyaProvider<Target> {

    private let online: Observable<Bool>

    init(endpointClosure: MoyaProvider<Target>.EndpointClosure = MoyaProvider.DefaultEndpointMapping,
        requestClosure: MoyaProvider<Target>.RequestClosure = MoyaProvider.DefaultRequestMapping,
        stubClosure: MoyaProvider<Target>.StubClosure = MoyaProvider.NeverStub,
        manager: Manager = Alamofire.Manager.sharedInstance,
        plugins: [PluginType] = [],
        online: Observable<Bool> = connectedToInternetOrStubbing()) {

            self.online = online
            super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: plugins)
    }

    override func request(token: Target) -> Observable<Moya.Response> {
        let actualRequest = super.request(token)
        return online
            .ignore(false)  // Wait until we're online
            .take(1)        // Take 1 to make sure we only invoke the API once.
            .flatMap { _ in // Turn the online state into a network request
                return actualRequest
            }

    }
}

protocol NetworkingType {
    typealias T: TargetType, ArtsyAPIType
    var provider: OnlineProvider<T> { get }
}

struct Networking: NetworkingType {
    typealias T = ArtsyAPI
    let provider: OnlineProvider<ArtsyAPI>
}

struct AuthorizedNetworking: NetworkingType {
    typealias T = ArtsyAuthenticatedAPI
    let provider: OnlineProvider<ArtsyAuthenticatedAPI>
}

private extension Networking {

    /// Request to fetch and store new XApp token if the current token is missing or expired.
    func XAppTokenRequest(defaults: NSUserDefaults) -> Observable<String?> {

        var appToken = XAppToken(defaults: defaults)

        // If we have a valid token, return it and forgo a request for a fresh one.
        if appToken.isValid {
            return Observable.just(appToken.token)
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
                // These two lines set the defaults values injected into appToken
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

// "Public" interfaces
extension Networking {
    /// Request to fetch a given target. Ensures that valid XApp tokens exist before making request
    func request(token: ArtsyAPI, defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) -> Observable<Moya.Response> {

        let actualRequest = self.provider.request(token)
        return self.XAppTokenRequest(defaults).flatMap { _ in actualRequest }
    }
}

extension AuthorizedNetworking {
    func request(token: ArtsyAuthenticatedAPI, defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) -> Observable<Moya.Response> {
        return self.provider.request(token)
    }
}

// Static methods
extension NetworkingType {

    static func newDefaultNetworking() -> Networking {
        return Networking(provider: newProvider(plugins))
    }

    static func newAuthorizedNetworking(xAccessToken: String) -> AuthorizedNetworking {
        return AuthorizedNetworking(provider: newProvider(authenticatedPlugins, xAccessToken: xAccessToken))
    }

    static func newStubbingNetworking() -> Networking {
        return Networking(provider: OnlineProvider(endpointClosure: endpointsClosure(), requestClosure: Networking.endpointResolver(), stubClosure: MoyaProvider.ImmediatelyStub, online: .just(true)))
    }

    static func newAuthorizedStubbingNetworking() -> AuthorizedNetworking {
        return AuthorizedNetworking(provider: OnlineProvider(endpointClosure: endpointsClosure(), requestClosure: Networking.endpointResolver(), stubClosure: MoyaProvider.ImmediatelyStub, online: .just(true)))
    }

    static func endpointsClosure<T where T: TargetType, T: ArtsyAPIType>(xAccessToken: String? = nil)(_ target: T) -> Endpoint<T> {
        var endpoint: Endpoint<T> = Endpoint<T>(URL: url(target), sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)

        // If we were given an xAccessToken, add it
        if let xAccessToken = xAccessToken {
            endpoint = endpoint.endpointByAddingHTTPHeaderFields(["X-Access-Token": xAccessToken])
        }

        // Sign all non-XApp, non-XAuth token requests
        if target.addXAuth {
            return endpoint.endpointByAddingHTTPHeaderFields(["X-Xapp-Token": XAppToken().token ?? ""])
        } else {
            return endpoint
        }
    }

    static func APIKeysBasedStubBehaviour<T>(_: T) -> Moya.StubBehavior {
        return APIKeys.sharedKeys.stubResponses ? .Immediate : .Never
    }

    static var plugins: [PluginType] {
        return [
            NetworkLogger(blacklist: { target -> Bool in
                guard let target = target as? ArtsyAPI else { return false }

                switch target {
                case .Ping: return true
                default: return false
                }
            })
        ]
    }
    static var authenticatedPlugins: [PluginType] {
        return [NetworkLogger(whitelist: { target -> Bool in
            guard let target = target as? ArtsyAuthenticatedAPI else { return false }

            switch target {
            case .MyBidPosition: return true
            case .FindMyBidderRegistration: return true
            default: return false
            }
        })
        ]
    }

    // (Endpoint<Target>, NSURLRequest -> Void) -> Void
    static func endpointResolver<T where T: TargetType>() -> MoyaProvider<T>.RequestClosure {
        return { (endpoint, closure) in
            let request: NSMutableURLRequest = endpoint.urlRequest.mutableCopy() as! NSMutableURLRequest
            request.HTTPShouldHandleCookies = false
            closure(request)
        }
    }
}

private func newProvider<T where T: TargetType, T: ArtsyAPIType>(plugins: [PluginType], xAccessToken: String? = nil) -> OnlineProvider<T> {
    return OnlineProvider(endpointClosure: Networking.endpointsClosure(xAccessToken),
        requestClosure: Networking.endpointResolver(),
        stubClosure: Networking.APIKeysBasedStubBehaviour,
        plugins: plugins)
}
