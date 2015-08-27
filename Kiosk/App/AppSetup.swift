import UIKit

class AppSetup {

    var auctionID = "los-angeles-modern-auctions-march-2015"
    lazy var useStaging = true
    lazy var showDebugButtons = false
    lazy var disableCardReader = false
    var isTesting = false

    class var sharedState : AppSetup {
        struct Static {
            static let instance = AppSetup()
        }
        return Static.instance
    }

    init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let auction = defaults.stringForKey("KioskAuctionID") {
            auctionID = auction
        }

        useStaging = defaults.boolForKey("KioskUseStaging")
        showDebugButtons = defaults.boolForKey("KioskShowDebugButtons")
        disableCardReader = defaults.boolForKey("KioskDisableCardReader")

        if let _ = NSClassFromString("XCTest") { isTesting = true }
    }
}
