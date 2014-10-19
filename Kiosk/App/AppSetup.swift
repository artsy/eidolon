import UIKit

class AppSetup {

    var auctionID = "two-x-two-2014"
    var useStaging = true

//    var auctionID = "two-x-two-2014"
//    var useStaging = false


    class var sharedState : AppSetup {
        struct Static {
            static let instance : AppSetup = AppSetup()
        }
        return Static.instance
    }
}
