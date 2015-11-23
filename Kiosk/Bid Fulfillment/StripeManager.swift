import Foundation
import RxSwift
import Stripe

class StripeManager: NSObject {
    var stripeClient = STPAPIClient.sharedClient()

    func registerCard(digits: String, month: UInt, year: UInt, securityCode: String, postalCode: String) -> Observable<STPToken> {
        let card = STPCard()
        card.number = digits
        card.expMonth = month
        card.expYear = year
        card.cvc = securityCode
        card.addressZip = postalCode

        return create { [weak self] observer in
            guard let me = self else {
                observer.onCompleted()
                return NopDisposable.instance
            }

            me.stripeClient.createTokenWithCard(card) { (token, error) -> Void in
                if (token as STPToken?).hasValue {
                    observer.onNext(token)
                    observer.onCompleted()
                } else {
                    observer.onError(error)
                }
            }

            return NopDisposable.instance
        }
    }

    func stringIsCreditCard(cardNumber: String) -> Bool {
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
