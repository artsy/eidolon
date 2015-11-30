import UIKit
import RxSwift

class CardHandler: NSObject, CFTReaderDelegate {

    private let _cardStatus = PublishSubject<String>()

    var cardStatus: Observable<String> {
        return _cardStatus.asObservable()
    }

    var card: CFTCard?
    
    let APIKey: String
    let APIToken: String

    var reader: CFTReader!
    lazy var sessionManager = CFTSessionManager.sharedInstance()

    init(apiKey: String, accountToken: String){
        APIKey = apiKey
        APIToken = accountToken

        super.init()

        sessionManager.setApiToken(APIKey, accountToken: APIToken)
    }

    func startSearching() {
        sessionManager.setLogging(true)

        reader = CFTReader(reader: 1)
        reader.delegate = self
        reader.swipeHasTimeout(false)
        _cardStatus.onNext("Started searching")
    }

    func end() {
        reader.cancelTransaction()
        reader = nil
    }

    func readerCardResponse(card: CFTCard?, withError error: NSError?) {
        if let card = card {
            self.card = card;
            _cardStatus.onNext("Got Card")

            card.tokenizeCardWithSuccess({ [weak self] () -> Void in
                self?._cardStatus.onCompleted()
                logger.log("Card was tokenized")

            }, failure: { [weak self] (error) -> Void in
                self?._cardStatus.onNext("Card Flight Error: \(error)");
                logger.log("Card was not tokenizable")
            })
            
        } else if let error = error {
            self._cardStatus.onNext("response Error \(error)");
            logger.log("CardReader got a response it cannot handle")


            reader.beginSwipe();
        }
    }

    func transactionResult(charge: CFTCharge!, withError error: NSError!) {
        logger.log("Unexcepted call to transactionResult callback: \(charge)\n\(error)")
    }

    // handle other delegate call backs with the status messages

    func readerIsAttached() {
        _cardStatus.onNext("Reader is attatched");
    }

    func readerIsConnecting() {
        _cardStatus.onNext("Reader is connecting");
    }

    func readerIsDisconnected() {
        _cardStatus.onNext("Reader is disconnected");
        logger.log("Card Reader Disconnected")
    }

    func readerSwipeDidCancel() {
        _cardStatus.onNext("Reader did cancel");
        logger.log("Card Reader was Cancelled")
    }

    func readerGenericResponse(cardData: String!) {
        _cardStatus.onNext("Reader received non-card data: \(cardData) ");
        reader.beginSwipe()
    }

    func readerIsConnected(isConnected: Bool, withError error: NSError!) {
        if isConnected {
            _cardStatus.onNext("Reader is connected")
            reader.beginSwipe()
        } else {
            if (error != nil) {
                _cardStatus.onNext("Reader is disconnected: \(error.localizedDescription)");
            } else {
                _cardStatus.onNext("Reader is disconnected");
            }
        }
    }
}
