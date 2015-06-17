import Foundation

private extension NSDate {
    var isInPast: Bool {
        let now = NSDate()
        return self.compare(now) == NSComparisonResult.OrderedAscending
    }
}

public struct XAppToken {
    enum DefaultsKeys: String {
        case TokenKey = "TokenKey"
        case TokenExpiry = "TokenExpiry"
    }

    // MARK: - Initializers

    public let defaults: NSUserDefaults

    public init(defaults:NSUserDefaults) {
        self.defaults = defaults
    }

    public init() {
        self.defaults = NSUserDefaults.standardUserDefaults()
    }


    // MARK: - Properties
    
    public var token: String? {
        get {
            let key = defaults.stringForKey(DefaultsKeys.TokenKey.rawValue)
            return key
        }
        set(newToken) {
            defaults.setObject(newToken, forKey: DefaultsKeys.TokenKey.rawValue)
        }
    }
    
    public var expiry: NSDate? {
        get {
            return defaults.objectForKey(DefaultsKeys.TokenExpiry.rawValue) as? NSDate
        }
        set(newExpiry) {
            defaults.setObject(newExpiry, forKey: DefaultsKeys.TokenExpiry.rawValue)
        }
    }
    
    public var expired: Bool {
        if let expiry = expiry {
            return expiry.isInPast
        }
        return true
    }
    
    public var isValid: Bool {
        if let token = token {
            return count(token) > 0 && !expired
        }
            
        return false
    }
}
