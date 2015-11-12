import UIKit
import RxSwift

class CardHandler: NSObject, CFTReaderDelegate {

    private let _cardStatus = BehaviorSubject(value: "")

    var cardStatus: Observable<String> {
        return _cardStatus.asObservable().skip(1)
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

        reader = CFTReader(andConnect: ())
        reader.delegate = self;
        reader.swipeTimeoutDuration(0)
        _cardStatus.onNext("Started searching")
    }

    func end() {
        reader.cancelSwipeWithMessage(nil)
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


            reader.beginSwipeWithMessage(nil);
        }
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
        reader.beginSwipeWithMessage(nil);
    }

    func readerIsConnected(isConnected: Bool, withError error: NSError!) {
        if isConnected {
            _cardStatus.onNext("Reader is connected");
            reader.beginSwipeWithMessage(nil);

        } else {
            if (error != nil) {
                _cardStatus.onNext("Reader is disconnected: \(error.localizedDescription)");
            } else {
                _cardStatus.onNext("Reader is disconnected");
            }
        }
    }
}
