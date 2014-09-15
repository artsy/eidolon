import Foundation

private extension NSDate {
    var isInPast: Bool {
        let now = NSDate.date()
        return self.compare(now) == NSComparisonResult.OrderedAscending
    }
}

public struct XAppToken {
    private enum DefaultsKeys: String {
        case TokenKey = "TokenKey"
        case TokenExpiry = "TokenExpiry"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
        
    // MARK: - Initializers

    public init() {
        // Empty, but necessary to invoke from tests
    }
    
    // MARK: - Properties
    
    public var token: String? {
        get {
            return defaults.stringForKey(DefaultsKeys.TokenKey.toRaw())
        }
        set(newToken) {
            defaults.setObject(newToken, forKey: DefaultsKeys.TokenKey.toRaw())
        }
    }
    
    public var expiry: NSDate? {
        get {
            return defaults.objectForKey(DefaultsKeys.TokenExpiry.toRaw()) as? NSDate
        }
        set(newExpiry) {
            defaults.setObject(newExpiry, forKey: DefaultsKeys.TokenExpiry.toRaw())
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
            return !expired
        }
            
        return false
    }
}
