import UIKit
import balanced_ios
import ReactiveCocoa

class BalancedManager: NSObject {

    let marketplace: String

    dynamic var cardName = ""
    dynamic var cardLastDigits = ""
    dynamic var cardToken = ""

    init(marketplace: String) {
        self.marketplace = marketplace
    }

    func registerCard(digits: String, month: Int, year: Int) -> RACSignal {
        let registeredCardSignal = RACSubject()

        let card = BPCard(number: digits, expirationMonth: UInt(month), expirationYear: UInt(year), optionalFields: nil)

        let balanced = Balanced(marketplaceURI:"/v1/marketplaces/\(marketplace)")

        balanced.tokenizeCard(card, onSuccess: { (dict) -> Void in
            if let data = dict["data"] as? [String: AnyObject] {

            // TODO: We don't capture names

            if let uri = data["uri"] as? String {
                self.cardToken = uri
            }

            if let last4 = data["last_four"] as? String {
                self.cardLastDigits = last4
            }

            self.cardName = data["name"] as? String ?? ""
            registeredCardSignal.sendNext(self)
        }

        }) { (error) -> Void in
            registeredCardSignal.sendError(error)
            logger.error("Error tokenizing via balanced: \(error)")
        }

        return registeredCardSignal
    }
}
