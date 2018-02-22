import Foundation

// This protocol represents a credit card from Stripe. But they recently changed their API so we can't mock things
// using it anymore, so we need to wrap their API in a protocol (so that we can mock it in tests).
protocol CreditCard {
    var name: String? { get }
    var brandName: String? { get }
    var last4: String { get }
}

import Stripe
extension STPCard: CreditCard {
    var brandName: String? {
        return self.brand.name
    }
}
