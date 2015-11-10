import Foundation
import ISO8601DateFormatter
import Moya
import RxSwift

/// Request to fetch and store new XApp token if the current token is missing or expired.

private func XAppTokenRequest(defaults: NSUserDefaults) -> RACSignal {

    // I don't like an extension of a class referencing what is essentially a singleton of that class.
    var appToken = XAppToken(defaults: defaults)

    let newTokenSignal = Provider.sharedProvider.request(ArtsyAPI.XApp).filterSuccessfulStatusCodes().mapJSON().doNext({ (response) -> Void in
        if let dictionary = response as? NSDictionary {
            let formatter = ISO8601DateFormatter()
            appToken.token = dictionary["xapp_token"] as? String
            appToken.expiry = formatter.dateFromString(dictionary["expires_in"] as? String)
        }
    }).logError().ignoreValues()

    // Signal that returns whether our current token is valid
    let validTokenSignal = RACSignal.`return`(appToken.isValid)

    // If the token is valid, just return an empty signal, otherwise return a signal that fetches new tokens
    return RACSignal.`if`(validTokenSignal, then: RACSignal.empty(), `else`: newTokenSignal)
}

/// Request to fetch a given target. Ensures that valid XApp tokens exist before making request
func XAppRequest(token: ArtsyAPI, provider: ArtsyProvider<ArtsyAPI> = Provider.sharedProvider, defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) -> RACSignal {

    return provider.onlineSignal.ignore(false).take(1).then {
        // First perform XAppTokenRequest(). When it completes, then the signal returned from the closure will be subscribed to.
        XAppTokenRequest(defaults).then {
            return provider.request(token)
        }
    }
}