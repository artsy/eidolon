import Quick
import Nimble
@testable
import Kiosk
import RxSwift
import CardFlight
import RxBlocking

class CardHandlerTests: QuickSpec {

    override func spec() {
        let apiKey = "jhfbsdhbfsd"
        let accountToken = "dxcvxfvdfgvxcv"

        var handler: CardHandler!
        var transaction: LocalTransaction!
        var disposeBag: DisposeBag!

        beforeEach {
            handler = CardHandler(apiKey: apiKey, accountToken: accountToken)
            transaction = LocalTransaction(delegate: handler)
            handler.transaction = transaction

            disposeBag = DisposeBag()
        }

        it("sets up the Cardflight API + Token") {
            handler.startSearching()
            expect(transaction.receivedTokenizationParameters?.credentials.apiKey) == apiKey
            expect(transaction.receivedTokenizationParameters?.credentials.accountToken) == accountToken
        }

        it("sends an observable with a card if successful") {
            var success = false
            handler
                .cardStatus
                .subscribe(onCompleted: {
                    success = true
                })
                .disposed(by: disposeBag)

            handler.startSearching()
            expect(success) == true
            expect(handler.card).toNot( beNil() )
        }

        it("sends an observable with an error if failed") {
            transaction.fail = true

            var failed = false
            handler
                .cardStatus
                .subscribe(onNext: { message in
                    failed = failed || message.contains("Error")
                })
                .disposed(by: disposeBag)

            handler!.startSearching()
            expect(failed) == true
        }

        it("passes user messages through an observable") {
            var messages = Array<String>()
            handler.userMessages.subscribe(onNext: { (message) in
                messages.append(message)
            }).disposed(by: disposeBag)

            let message = CFTMessage()
            message.setValue("Hello there", forKey: "primary")
            handler.transaction(transaction, didRequestDisplay: message)

            expect(messages) == ["Hello there"]
        }

        it("filters user messages that end in a question mark") {
            var messages = Array<String>()
            handler.userMessages.subscribe(onNext: { (message) in
                messages.append(message)
            }).disposed(by: disposeBag)

            let message = CFTMessage()
            message.setValue("Process ARTSYCARD 1234?", forKey: "primary")
            handler.transaction(transaction, didRequestDisplay: message)

            expect(messages).to( beEmpty() )
        }
    }
}

class LocalTransaction: CFTTransaction {
    enum TestError: Swift.Error {
        case error
    }

    var fail = false
    var callCount = 0

    var receivedTokenizationParameters: CFTTokenizationParameters?

    // This is a stub method for the _real_ beginTokenizing(tokenizationParameters:). It does not call super.
    override func beginTokenizing(tokenizationParameters: CFTTokenizationParameters) {
        // We only want our tests to handle this call once, since they are synchronous and we will get into an infinite
        // loop otherwise.
        guard callCount < 1 else { return }
        callCount += 1

        self.receivedTokenizationParameters = tokenizationParameters

        // This object has only read-only properties, so we need to be sneaky and use ObjC.
        let historicalTransaction = CFTHistoricalTransaction()
        if fail {
            historicalTransaction.setValue(TestError.error, forKey: "error")
        } else {
            let cardInfo = CFTCardInfo()
            historicalTransaction.setValue(cardInfo, forKey: "cardInfo")
            historicalTransaction.setValue("some-token", forKey: "cardToken")
        }
        delegate?.transaction(self, didComplete: historicalTransaction)
    }
}
