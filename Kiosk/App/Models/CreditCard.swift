import Foundation

// This protocol represents a credit card from Stripe. But they recently changed their API so we can't mock things
// using it anymore, so we need to wrap their API in a protocol (so that we can mock it in tests).
@objc protocol CreditCard {

}

import Stripe
extension STPCard: CreditCard {}
