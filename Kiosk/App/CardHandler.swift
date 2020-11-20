import UIKit
import RxSwift

internal final class DummyCard: NSObject {
    
    internal init(token: String, cardInfo: DummyCard.DummyCardInfo) {
        self.token = token
        self.cardInfo = cardInfo
    }
    
    let token: String
    let cardInfo: DummyCardInfo
    
    internal final class DummyCardInfo: NSObject {
        
        internal init(cardholderName: String, lastFour: String) {
            self.cardholderName = cardholderName
            self.lastFour = lastFour
        }
        
        let cardholderName: String
        let lastFour: String
    }
}

class CardHandler: NSObject {

    private let _cardStatus = PublishSubject<String>()
    private let _userMessages = PublishSubject<String>()
    
    var card: DummyCard?

    var cardStatus: Observable<String> {
        return _cardStatus.asObservable()
    }

    var userMessages: Observable<String> {
        // User messages are things like "Swipe card", "processing", or "Swipe card again". Due to a problem with the
        // CardFlight SDK, the user is prompted to accept processing for card tokenization, which is provides a
        // unfriendly user experience (prompting to accept a transaction that we're not actually placing). So we
        // auto-accept these requests and filter out confirmation messages, which don't apply to tokenization flows,
        // until this issue is fixed: https://github.com/CardFlight/cardflight-v4-ios/issues/4
        return _userMessages
            .asObservable()
            .filter { message -> Bool in
                !message.hasSuffix("?")
            }
    }

    let APIKey: String
    let APIToken: String

    init(apiKey: String, accountToken: String){
        APIKey = apiKey
        APIToken = accountToken

        super.init()
    }

    deinit {
        self.end()
    }

    func startSearching() {
        _cardStatus.onNext("Starting search...")
    }

    func end() {
    }
}
