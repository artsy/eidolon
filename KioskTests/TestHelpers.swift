//
//  TestHelpers.swift
//  Kiosk
//
//  Created by Ash Furrow on 2014-09-15.
//  Copyright (c) 2014 Artsy. All rights reserved.
//

import Foundation

private enum DefaultsKeys: String {
    case TokenKey = "TokenKey"
    case TokenExpiry = "TokenExpiry"
}

let defaults = NSUserDefaults.standardUserDefaults()

func clearDefaultsKeys() {
    defaults.removeObjectForKey(DefaultsKeys.TokenKey.toRaw())
    defaults.removeObjectForKey(DefaultsKeys.TokenExpiry.toRaw())
}

func getDefaultsKeys() -> (key: String?, expiry: NSDate?) {
    let key = defaults.objectForKey(DefaultsKeys.TokenKey.toRaw()) as String?
    let expiry = defaults.objectForKey(DefaultsKeys.TokenExpiry.toRaw()) as NSDate?
    
    return (key: key, expiry: expiry)
}

func setDefaultsKeys(key: String?, expiry: NSDate?) {
    defaults.setObject(key, forKey: DefaultsKeys.TokenKey.toRaw())
    defaults.setObject(expiry, forKey: DefaultsKeys.TokenExpiry.toRaw())
}
