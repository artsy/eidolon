import Foundation
import RxSwift
import Action
import Stripe

class ManualCreditCardInputViewModel: NSObject {

    /// MARK: - Things the user is entering (expecting to be bound to s)

    var cardFullDigits = Variable("")
    var expirationMonth = Variable("")
    var expirationYear = Variable("")
    var securityCode = Variable("")
    var billingZip = Variable("")

    private(set) var bidDetails: BidDetails!
    private(set) var finishedSubject: PublishSubject<Void>?

    /// Mark: - Public members

    init(bidDetails: BidDetails!, finishedSubject: PublishSubject<Void>? = nil) {
        super.init()

        self.bidDetails = bidDetails
        self.finishedSubject = finishedSubject
    }

    var creditCardNumberIsValid: Observable<Bool> {
        return cardFullDigits.asObservable().map(stripeManager.stringIsCreditCard)
    }

    var expiryDatesAreValid: Observable<Bool> {
        let month = expirationMonth.asObservable().map(isStringLengthIn(1..<3))
        let year = expirationYear.asObservable().map(isStringLengthOneOf([2,4]))

        return [month, year].combineLatestAnd()
    }

    var securityCodeIsValid: Observable<Bool> {
        return securityCode.asObservable().map(isStringLengthIn(3..<5))
    }

    var billingZipIsValid: Observable<Bool> {
        return billingZip.asObservable().map(isStringLengthIn(4..<8))
    }

    var moveToYear: Observable<Void> {
        return expirationMonth.asObservable().filter{ value in
            return value.characters.count == 2
        }.map(void)
    }

    func registerButtonCommand() -> CocoaAction {
        let newUser = bidDetails.newUser
        let enabled = [creditCardNumberIsValid, expiryDatesAreValid, securityCodeIsValid, billingZipIsValid].combineLatestAnd()

        return CocoaAction(enabledIf: enabled) { [weak self] _ in
            guard let me = self else {
                return .empty()
            }

            return me.registerCard(newUser).doOnCompleted {
                me.finishedSubject?.onCompleted()
            }.map(void)
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

    private func registerCard(newUser: NewUser) -> Observable<STPToken> {
        let month = expirationMonth.value.toUIntWithDefault(0)
        let year = expirationYear.value.toUIntWithDefault(0)

        return stripeManager.registerCard(cardFullDigits.value, month: month, year: year, securityCode: securityCode.value, postalCode: billingZip.value).doOnNext { token in

            newUser.creditCardName.value = token.card!.name
            newUser.creditCardType.value = token.card!.brand.name
            newUser.creditCardToken.value = token.tokenId
            newUser.creditCardDigit.value = token.card!.last4()
        }
    }

    // Only set for testing purposes, otherwise ignore.
    lazy var stripeManager: StripeManager = StripeManager()
}
