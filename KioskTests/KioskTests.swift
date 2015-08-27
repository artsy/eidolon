import ObjectiveC
import UIKit
@testable
import Kiosk

var AssociatedObjectHandle: UInt8 = 0

extension UIViewController {
    func wrapInFulfillmentNav() -> UIViewController {
        let nav = FulfillmentNavigationController(rootViewController: self)
        nav.auctionID = ""
        objc_setAssociatedObject(self, &AssociatedObjectHandle, nav, .OBJC_ASSOCIATION_RETAIN)
        return self
    }
}

let auctionStoryboard = UIStoryboard.auction()
let fulfillmentStoryboard = UIStoryboard.fulfillment()
