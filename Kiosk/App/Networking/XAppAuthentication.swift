import Foundation

/// Request to fetch and store new XApp token if the current token is missing or expired.

private func XAppTokenRequest(defaults: NSUserDefaults) -> RACSignal {

    // I don't like an extension of a class referencing what is essentially a singleton of that class.
    var appToken = XAppToken(defaults: defaults)

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

func XAppRequest(token: ArtsyAPI, method: Moya.Method = Moya.DefaultMethod(), parameters: [String: AnyObject] = Moya.DefaultParameters(), defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) -> RACSignal {

    // First perform XAppTokenRequest(). When it completes, then the signal returned from the closure will be subscribed to.

    return XAppTokenRequest(defaults).then({ () -> RACSignal! in
        return Provider.sharedProvider.request(token, method: method, parameters: parameters)
    })
}