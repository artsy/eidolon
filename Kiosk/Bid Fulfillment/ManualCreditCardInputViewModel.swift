import Foundation
import ReactiveCocoa
import Swift_RAC_Macros
import Stripe

public class ManualCreditCardInputViewModel: NSObject {

    /// MARK: - Things the user is entering (expecting to be bound to signals)

    public dynamic var cardFullDigits = ""
    public dynamic var expirationMonth = ""
    public dynamic var expirationYear = ""

    public private(set) var bidDetails: BidDetails!

    /// Mark: - Public members

    public init(bidDetails: BidDetails!) {
        super.init()

        self.bidDetails = bidDetails
    }

    public var creditCardNumberIsValidSignal: RACSignal {
        return RACObserve(self, "cardFullDigits").map(stripeManager.stringIsCreditCard)
    }

    public var expiryDatesAreValidSignal: RACSignal {
        let monthSignal = RACObserve(self, "expirationMonth").map(isStringLengthIn(1..<3))
        let yearSignal = RACObserve(self, "expirationYear").map(isStringLengthOneOf([2,4]))

        return RACSignal.combineLatest([yearSignal, monthSignal]).and()
    }

    public var moveToYearSignal: RACSignal {
        return RACObserve(self, "expirationMonth").filter { (value) -> Bool in
            return count(value as! String) == 2
        }
    }

    public func registerButtonCommand() -> RACCommand {
        let newUser = bidDetails.newUser
        let enabled = RACSignal.combineLatest([creditCardNumberIsValidSignal, expiryDatesAreValidSignal]).and()
        return RACCommand(enabled: enabled) { [weak self] _ in
            self?.registerCardSignal(newUser) ?? RACSignal.empty()
        }
    }

    public func isEntryValid(entry: String) -> Bool {
        // Allow delete
        if (count(entry) == 0) { return true }

        // the API doesn't accept chars
        let notNumberChars = NSCharacterSet.decimalDigitCharacterSet().invertedSet;
        return count(entry.stringByTrimmingCharactersInSet(notNumberChars)) != 0
    }

    /// MARK: - Private Methods

    private func registerCardSignal(newUser: NewUser) -> RACSignal {
        let month = expirationMonth.toUInt(defaultValue: 0)
        let year = expirationYear.toUInt(defaultValue: 0)

        return stripeManager.registerCard(cardFullDigits, month: month, year: year).doNext() { (object) in
            let token = object as! STPToken

            newUser.creditCardName = token.card.name
            newUser.creditCardType = token.card.brand.name
            newUser.creditCardToken = token.tokenId
            newUser.creditCardDigit = token.card.last4
        }
    }

    // Only public for testing purposes
    public lazy var stripeManager: StripeManager = StripeManager()
}
