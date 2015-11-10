import Foundation
import RxSwift
import Stripe

class StripeManager: NSObject {
    var stripeClient = STPAPIClient.sharedClient()

    func registerCard(digits: String, month: UInt, year: UInt, securityCode: String, postalCode: String) -> RACSignal {
        let card = STPCard()
        card.number = digits
        card.expMonth = month
        card.expYear = year
        card.cvc = securityCode
        card.addressZip = postalCode

        return RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            self?.stripeClient.createTokenWithCard(card) { (token, error) -> Void in
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

    func stringIsCreditCard(object: AnyObject!) -> AnyObject! {
        let cardNumber = object as! String

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
