import UIKit
import ReactiveCocoa

class CardHandler: NSObject, CFTReaderDelegate {

    let cardSwipedSignal = RACSubject()
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
        cardSwipedSignal.sendNext("Started searching");
    }

    func end() {
        reader.cancelSwipeWithMessage(nil)
        reader = nil
    }

    func readerCardResponse(card: CFTCard?, withError error: NSError?) {
        if let card = card {
            self.card = card;
            cardSwipedSignal.sendNext("Got Card")

            card.tokenizeCardWithSuccess({ () -> Void in
                self.cardSwipedSignal.sendCompleted()
                logger.log("Card was tokenized")


            }, failure: { (error) -> Void in
                self.cardSwipedSignal.sendNext("Card Flight Error: \(error)");
                logger.log("Card was not tokenizable")
            })
            
        } else if let error = error {
            self.cardSwipedSignal.sendNext("response Error \(error)");
            logger.log("CardReader got a response it cannot handle")


            reader.beginSwipeWithMessage(nil);
        }
    }

    // handle other delegate call backs with the status messages

    func readerIsAttached() {
        cardSwipedSignal.sendNext("Reader is attatched");
    }

    func readerIsConnecting() {
        cardSwipedSignal.sendNext("Reader is connecting");
    }

    func readerIsDisconnected() {
        cardSwipedSignal.sendNext("Reader is disconnected");
        logger.log("Card Reader Disconnected")
    }

    func readerSwipeDidCancel() {
        cardSwipedSignal.sendNext("Reader did cancel");
        logger.log("Card Reader was Cancelled")
    }

    func readerGenericResponse(cardData: String!) {
        cardSwipedSignal.sendNext("Reader received non-card data: \(cardData) ");
        reader.beginSwipeWithMessage(nil);
    }

    func readerIsConnected(isConnected: Bool, withError error: NSError!) {
        if isConnected {
            cardSwipedSignal.sendNext("Reader is connected");
            reader.beginSwipeWithMessage(nil);

        } else {
            if (error != nil) {
                cardSwipedSignal.sendNext("Reader is disconnected: \(error.localizedDescription)");
            } else {
                cardSwipedSignal.sendNext("Reader is disconnected");
            }
        }
    }
}

class LocalCardReader: CFTReader {
    var fail = false

    override func beginSwipeWithMessage(message: String!) {
        if fail {
            let error = NSError(domain: "eidolon", code: 111, userInfo: nil)
            self.delegate?.readerCardResponse(nil, withError: error)

        } else {
            self.delegate?.readerCardResponse(CFTCard(), withError: nil)
        }
    }
}