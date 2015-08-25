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
    public private(set) var finishedSubject: RACSubject?

    /// Mark: - Public members

    public init(bidDetails: BidDetails!, finishedSubject: RACSubject? = nil) {
        super.init()

        self.bidDetails = bidDetails
        self.finishedSubject = finishedSubject
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
            return (value as! String).characters.count == 2
        }
    }

    public func registerButtonCommand() -> RACCommand {
        let newUser = bidDetails.newUser
        let enabled = RACSignal.combineLatest([creditCardNumberIsValidSignal, expiryDatesAreValidSignal]).and()
        return RACCommand(enabled: enabled) { [weak self] _ in
            (self?.registerCardSignal(newUser) ?? RACSignal.empty())?.doCompleted { () -> Void in
                self?.finishedSubject?.sendCompleted()
            }
        }
    }

    public func isEntryValid(entry: String) -> Bool {
        // Allow delete
        if (entry.isEmpty) { return true }

        // the API doesn't accept chars
        let notNumberChars = NSCharacterSet.decimalDigitCharacterSet().invertedSet;
        return !entry.stringByTrimmingCharactersInSet(notNumberChars).isEmpty
    }

    /// MARK: - Private Methods

    private func registerCardSignal(newUser: NewUser) -> RACSignal {
        let month = expirationMonth.toUInt(0)
        let year = expirationYear.toUInt(0)

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
