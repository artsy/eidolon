import UIKit
import RxSwift
import CardFlight

class CardHandler: NSObject, CFTTransactionDelegate {

    fileprivate let _cardStatus = PublishSubject<String>()

    var cardStatus: Observable<String> {
        return _cardStatus.asObservable()
    }

    var cardFlightCredentials: CFTCredentials {
        let credentials = CFTCredentials()
        credentials.setup(apiKey: self.APIKey, accountToken: self.APIToken, completion: nil)
        return credentials
    }

    var transaction: CFTTransaction?
    var card: (cardInfo: CFTCardInfo, token: String)?

    let APIKey: String
    let APIToken: String

    init(apiKey: String, accountToken: String){
        APIKey = apiKey
        APIToken = accountToken

        super.init()
    }

    func startSearching() {
        self.transaction = CFTTransaction(delegate: self)
        let tokenizationParameters = CFTTokenizationParameters(customerId: nil, credentials: self.cardFlightCredentials)
        transaction?.beginTokenizing(tokenizationParameters: tokenizationParameters)
        _cardStatus.onNext("Started searching")
    }

    func end() {
        // TODO: Cancel transaction

    }

    func transaction(_ transaction: CFTTransaction, didUpdate state: CFTTransactionState, error: Error?) {
        // TODO: Update _cardStatus
    }

    public func transaction(_ transaction: CFTTransaction, didComplete historicalTransaction: CFTHistoricalTransaction) {
        if let cardInfo = historicalTransaction.cardInfo, let token = historicalTransaction.cardToken {
            self.card = (cardInfo: cardInfo, token: token)
            _cardStatus.onNext("Got Card")
            self._cardStatus.onCompleted()
        } else {
            _cardStatus.onNext("Card Flight Error – could not retrieve card data.");
            if let error = historicalTransaction.error {
                self._cardStatus.onNext("response Error \(error)");
                logger.log("CardReader got a response it cannot handle")
            }
            startSearching()
        }
    }

    func transaction(_ transaction: CFTTransaction, didRequestDisplay message: CFTMessage) {
        // TODO
    }

    func transaction(_ transaction: CFTTransaction, didRequestProcessOption cardInfo: CFTCardInfo) {
        // TODO:
    }

    func transaction(_ transaction: CFTTransaction, didDefer transactionData: Data) {
        // TODO:
    }

    public func transaction(_ transaction: CFTTransaction, didRequest cvm: CFTCVM) {
        // Not required, we're not making chargers
    }

    public func transaction(_ transaction: CFTTransaction, didReceive cardReaderEvent: CFTCardReaderEvent, cardReaderInfo: CFTCardReaderInfo?) {

    }

//    func readerIsAttached() {
//        _cardStatus.onNext("Reader is attatched");
//    }
//
//    func readerIsConnecting() {
//        _cardStatus.onNext("Reader is connecting");
//    }
//
//    func readerIsDisconnected() {
//        _cardStatus.onNext("Reader is disconnected");
//        logger.log("Card Reader Disconnected")
//    }
//
//    func readerSwipeDidCancel() {
//        _cardStatus.onNext("Reader did cancel");
//        logger.log("Card Reader was Cancelled")
//    }
//
//    func readerGenericResponse(_ cardData: String!) {
//        _cardStatus.onNext("Reader received non-card data: \(cardData ?? "") ");
//        reader.beginSwipe()
//    }
//
//    func readerIsConnected(_ isConnected: Bool, withError error: Error!) {
//        if isConnected {
//            _cardStatus.onNext("Reader is connected")
//            reader.beginSwipe()
//        } else {
//            if (error != nil) {
//                _cardStatus.onNext("Reader is disconnected: \(error.localizedDescription)");
//            } else {
//                _cardStatus.onNext("Reader is disconnected");
//            }
//        }
//    }
}
