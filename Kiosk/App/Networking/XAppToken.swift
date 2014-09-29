import Foundation

private extension NSDate {
    var isInPast: Bool {
        let now = NSDate()
        return self.compare(now) == NSComparisonResult.OrderedAscending
    }
}

struct XAppToken {
    private enum DefaultsKeys: String {
        case TokenKey = "TokenKey"
        case TokenExpiry = "TokenExpiry"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
        
    // MARK: - Initializers

    init() {
        // Empty, but necessary to invoke from tests
    }
    
    // MARK: - Properties
    
    var token: String? {
        get {
            let key = defaults.stringForKey(DefaultsKeys.TokenKey.rawValue)
            return key
        }
        set(newToken) {
            defaults.setObject(newToken, forKey: DefaultsKeys.TokenKey.rawValue)
        }
    }
    
    var expiry: NSDate? {
        get {
            return defaults.objectForKey(DefaultsKeys.TokenExpiry.rawValue) as? NSDate
        }
        set(newExpiry) {
            defaults.setObject(newExpiry, forKey: DefaultsKeys.TokenExpiry.rawValue)
        }
    }
    
    var expired: Bool {
        if let expiry = expiry {
            return expiry.isInPast
        }
        return true
    }
    
    var isValid: Bool {
        if let token = token {
            return countElements(token) > 0 && !expired
        }
            
        return false
    }
}
