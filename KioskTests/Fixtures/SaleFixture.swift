import Foundation
@testable import Kiosk

func makeSale(startAt: Date = NSDate.distantPast, endAt: Date = NSDate.distantFuture) -> Sale {
    return Sale.fromJSON([
        "start_at": ISO8601DateFormatter().string(from: startAt) as AnyObject,
        "end_at" : ISO8601DateFormatter().string(from: endAt) as AnyObject
        ])
}
