//
//  XAppToken.swift
//  Kiosk
//
//  Created by Ash Furrow on 2014-09-13.
//  Copyright (c) 2014 Artsy. All rights reserved.
//

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
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var token: NSString? {
        get {
            return defaults.stringForKey(DefaultsKeys.TokenKey.toRaw())
        }
        set(newToken) {
            defaults.setObject(newToken, forKey: DefaultsKeys.TokenKey.toRaw())
        }
    }
    
    var expiry: NSDate? {
        get {
            return defaults.objectForKey(DefaultsKeys.TokenExpiry.toRaw()) as? NSDate
        }
        set(newExpiry) {
            defaults.setObject(newExpiry, forKey: DefaultsKeys.TokenExpiry.toRaw())
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
            return !expired
        }
            
        return false
    }
}
