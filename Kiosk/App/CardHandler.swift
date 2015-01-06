import UIKit
import CardFlight
import ReactiveCocoa

public class CardHandler: NSObject, CFTReaderDelegate {

    public let cardSwipedSignal = RACSubject()
    public var card: CFTCard?
    
    public let APIKey: String
    public let APIToken: String

    public var reader: CFTReader!
    public lazy var sessionManager = CFTSessionManager.sharedInstance()

    public init(apiKey: String, accountToken: String){
        APIKey = apiKey
        APIToken = accountToken

        super.init()

        sessionManager.setApiToken(APIKey, accountToken: APIToken)
    }

    public func startSearching() {
        sessionManager.setLogging(true)

        reader = CFTReader(andConnect: ())
        reader.delegate = self;
        reader.swipeTimeoutDuration(0)
        cardSwipedSignal.sendNext("Started searching");
    }

    public func end() {
        reader.cancelSwipeWithMessage(nil)
        reader = nil
    }

    public func readerCardResponse(card: CFTCard?, withError error: NSError?) {
        if let card = card {
            self.card = card;
            cardSwipedSignal.sendNext("Got Card")

            card.tokenizeCardWithSuccess({ () -> Void in
                self.cardSwipedSignal.sendCompleted()
                logger.error("Card was tokenized")


            }, failure: { (error) -> Void in
                self.cardSwipedSignal.sendNext("Card Flight Error: \(error)");
                logger.error("Card was not tokenizable")
            })
            
        } else if let error = error {
            self.cardSwipedSignal.sendNext("response Error");
            logger.error("CardReader got a response it cannot handle")


            reader.beginSwipeWithMessage(nil);
        }
    }

    // handle other delegate call backs with the status messages

    public func readerIsAttached() {
        cardSwipedSignal.sendNext("Reader is attatched");
    }

    public func readerIsConnecting() {
        cardSwipedSignal.sendNext("Reader is connecting");
    }

    public func readerIsDisconnected() {
        cardSwipedSignal.sendNext("Reader is disconnected");
        logger.error("Card Reader Disconnected")
    }

    public func readerSwipeDidCancel() {
        cardSwipedSignal.sendNext("Reader did cancel");
        logger.error("Card Reader was Cancelled")
    }

    public func readerGenericResponse(cardData: String!) {
        cardSwipedSignal.sendNext("Reader received non-card data: \(cardData) ");
        reader.beginSwipeWithMessage(nil);
    }

    public func readerIsConnected(isConnected: Bool, withError error: NSError!) {
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

public class LocalCardReader: CFTReader {
    public var fail = false

    override public func beginSwipeWithMessage(message: String!) {
        if fail {
            let error = NSError(domain: "eidolon", code: 111, userInfo: nil)
            self.delegate.readerCardResponse(nil, withError: error)

        } else {
            self.delegate.readerCardResponse(CFTCard(), withError: nil)
        }
    }
}