import Foundation
import ISO8601DateFormatter
import Moya
import RxSwift

/// Request to fetch and store new XApp token if the current token is missing or expired.

private func XAppTokenRequest(defaults: NSUserDefaults) -> Observable<String?> {

    var appToken = XAppToken(defaults: defaults)

    // If we have a valid token, return it and forgo a request for a fresh one.
    if appToken.isValid {
        return just(appToken.token)
    }

    let newTokenRequest = Provider.sharedProvider.request(ArtsyAPI.XApp)
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

/// Request to fetch a given target. Ensures that valid XApp tokens exist before making request
func XAppRequest(token: ArtsyAPI, provider: ArtsyProvider<ArtsyAPI> = Provider.sharedProvider, defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) -> Observable<MoyaResponse> {

    return provider.online
        .ignore(false)  // Wait unti we're online
        .take(1)        // Take 1 to make sure we only invoke the API once.
        .flatMap { _ in // Turn the online state into a network request
            return XAppTokenRequest(defaults).map { _ in provider.request(token) }
        .switchLatest() // Subscribe to the network request
    }
}
