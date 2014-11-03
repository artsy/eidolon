import UIKit

class AppSetup {

    lazy var auctionID = "two-x-two-2014"
    lazy var useStaging = true
    lazy var showDebugButtons = false
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

        if let inTests: AnyClass = NSClassFromString("XCTest") { isTesting = true }
    }
}
