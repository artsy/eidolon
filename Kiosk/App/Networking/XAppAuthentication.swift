import Foundation
import ISO8601DateFormatter
import Moya
import RxSwift

/// Request to fetch and store new XApp token if the current token is missing or expired.

private func XAppTokenRequest(defaults: NSUserDefaults) -> Observable<AnyObject> {

    // I don't like an extension of a class referencing what is essentially a singleton of that class.
    var appToken = XAppToken(defaults: defaults)

    let newTokenRequest = Provider.sharedProvider.request(ArtsyAPI.XApp).filterSuccessfulStatusCodes().mapJSON().doOn { event in
        if let dictionary = event.element as? NSDictionary {
            let formatter = ISO8601DateFormatter()
            appToken.token = dictionary["xapp_token"] as? String
            appToken.expiry = formatter.dateFromString(dictionary["expires_in"] as? String)
        }

    }.logError().ignoreElements()

    if appToken.isValid {
        return just(appToken.token!)
    } else {
        return newTokenRequest
    }
}

/// Request to fetch a given target. Ensures that valid XApp tokens exist before making request
func XAppRequest(token: ArtsyAPI, provider: ArtsyProvider<ArtsyAPI> = Provider.sharedProvider, defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) -> Observable<MoyaResponse> {

    // TODO: Incorrect, shouldn't use flatMap since XAppTokenRequest sends no values.
    return provider.online.ignore(false).take(1).flatMap({ (_) -> Observable<MoyaResponse> in
        return XAppTokenRequest(defaults).flatMap({ (_) -> Observable<MoyaResponse> in
            return provider.request(token)
        })
    })
}
