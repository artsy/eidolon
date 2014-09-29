import Foundation
import Quick

private enum DefaultsKeys: String {
    case TokenKey = "TokenKey"
    case TokenExpiry = "TokenExpiry"
}

let defaults = NSUserDefaults.standardUserDefaults()

func clearDefaultsKeys() {
    defaults.removeObjectForKey(DefaultsKeys.TokenKey.rawValue)
    defaults.removeObjectForKey(DefaultsKeys.TokenExpiry.rawValue)
}

func getDefaultsKeys() -> (key: String?, expiry: NSDate?) {
    let key = defaults.objectForKey(DefaultsKeys.TokenKey.rawValue) as String?
    let expiry = defaults.objectForKey(DefaultsKeys.TokenExpiry.rawValue) as NSDate?
    
    return (key: key, expiry: expiry)
}

func setDefaultsKeys(key: String?, expiry: NSDate?) {
    defaults.setObject(key, forKey: DefaultsKeys.TokenKey.rawValue)
    defaults.setObject(expiry, forKey: DefaultsKeys.TokenExpiry.rawValue)
}

func setupProviderForSuite(provider: ReactiveMoyaProvider<ArtsyAPI>) {
    beforeSuite { () -> () in
        Provider.sharedProvider = provider
    }

    afterSuite { () -> () in
        Provider.sharedProvider = Provider.DefaultProvider()
    }
}

func yearFromDate(date: NSDate) -> Int {
    let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
    return calendar.components(.CalendarUnitYear, fromDate: date).year
}