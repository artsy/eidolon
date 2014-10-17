import UIKit

class AppSetup {

    let auctionID = "ici-live-auction"
    let useStaging = true

    class var sharedState : AppSetup {
        struct Static {
            static let instance : AppSetup = AppSetup()
        }
        return Static.instance
    }
}
