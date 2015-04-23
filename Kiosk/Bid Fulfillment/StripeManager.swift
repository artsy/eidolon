import Foundation
import ReactiveCocoa
import Stripe

class StripeManager {
    class func registerCard(digits: String, month: UInt, year: UInt) -> RACSignal {
        let card = STPCard()
        card.number = digits
        card.expMonth = month
        card.expYear = year

        return RACSignal.createSignal { (subscriber) -> RACDisposable! in
            STPAPIClient.sharedClient().createTokenWithCard(card) { (token, error) -> Void in
                if (token as STPToken?).hasValue {
                    subscriber.sendNext(token)
                    subscriber.sendCompleted()
                } else {
                    subscriber.sendError(error)
                }
            }

            return nil
        }
    }

    class func stringIsCreditCard(object: AnyObject!) -> AnyObject! {
        let cardNumber = object as String

        return STPCard.validateCardNumber(cardNumber)
    }
}

extension STPCardBrand {
    var name: String? {
        switch self {
        case .Visa:
            return "Visa"
        case .Amex:
            return "American Express"
        case .MasterCard:
            return "MasterCard"
        case .Discover:
            return "Discover"
        case .JCB:
            return "JCB"
        case .DinersClub:
            return "Diners Club"
        default:
            return nil
        }
    }
}
