import Foundation
@testable import Kiosk

func makeSale(startAt: Date = NSDate.distantPast,
              endAt: Date = NSDate.distantFuture,
              bypassCreditCardRequirement: Bool = false) -> Sale {
    return Sale.fromJSON([
        "start_at": ISO8601DateFormatter().string(from: startAt),
        "end_at" : ISO8601DateFormatter().string(from: endAt),
        "trusted_client_bypasses_card_requirement": bypassCreditCardRequirement
        ])
}
