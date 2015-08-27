import Foundation
import ReactiveCocoa
import Swift_RAC_Macros
import Stripe

class ManualCreditCardInputViewModel: NSObject {

    /// MARK: - Things the user is entering (expecting to be bound to signals)

    dynamic var cardFullDigits = ""
    dynamic var expirationMonth = ""
    dynamic var expirationYear = ""

    private(set) var bidDetails: BidDetails!
    private(set) var finishedSubject: RACSubject?

    /// Mark: - Public members

    init(bidDetails: BidDetails!, finishedSubject: RACSubject? = nil) {
        super.init()

        self.bidDetails = bidDetails
        self.finishedSubject = finishedSubject
    }

    var creditCardNumberIsValidSignal: RACSignal {
        return RACObserve(self, "cardFullDigits").map(stripeManager.stringIsCreditCard)
    }

    var expiryDatesAreValidSignal: RACSignal {
        let monthSignal = RACObserve(self, "expirationMonth").map(isStringLengthIn(1..<3))
        let yearSignal = RACObserve(self, "expirationYear").map(isStringLengthOneOf([2,4]))

        return RACSignal.combineLatest([yearSignal, monthSignal]).and()
    }

    var moveToYearSignal: RACSignal {
        return RACObserve(self, "expirationMonth").filter { (value) -> Bool in
            return (value as! String).characters.count == 2
        }
    }

    func registerButtonCommand() -> RACCommand {
        let newUser = bidDetails.newUser
        let enabled = RACSignal.combineLatest([creditCardNumberIsValidSignal, expiryDatesAreValidSignal]).and()
        return RACCommand(enabled: enabled) { [weak self] _ in
            (self?.registerCardSignal(newUser) ?? RACSignal.empty())?.doCompleted { () -> Void in
                self?.finishedSubject?.sendCompleted()
            }
        }
    }

    func isEntryValid(entry: String) -> Bool {
        // Allow delete
        if (entry.isEmpty) { return true }

        // the API doesn't accept chars
        let notNumberChars = NSCharacterSet.decimalDigitCharacterSet().invertedSet;
        return entry.stringByTrimmingCharactersInSet(notNumberChars).isNotEmpty
    }

    /// MARK: - Private Methods

    private func registerCardSignal(newUser: NewUser) -> RACSignal {
        let month = expirationMonth.toUIntWithDefault(0)
        let year = expirationYear.toUIntWithDefault(0)

        return stripeManager.registerCard(cardFullDigits, month: month, year: year).doNext() { (object) in
            let token = object as! STPToken

            newUser.creditCardName = token.card.name
            newUser.creditCardType = token.card.brand.name
            newUser.creditCardToken = token.tokenId
            newUser.creditCardDigit = token.card.last4
        }
    }

    // Only for testing purposes
    lazy var stripeManager: StripeManager = StripeManager()
}
