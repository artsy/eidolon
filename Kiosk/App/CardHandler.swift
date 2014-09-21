import UIKit

public class CardHandler: NSObject, CFTReaderDelegate {

    public let cardSwipedSignal = RACSubject()
    public var card:CFTCard?
    
    let APIKey:String
    let APIToken:String

    public lazy var reader = CFTReader()
    public lazy var sessionManager = CFTSessionManager.sharedInstance()

    public init(apiKey:String, accountToken:String){
        APIKey = apiKey
        APIToken = accountToken
    }

    public func startSearching() {
        sessionManager.setApiToken(APIKey, accountToken: APIToken)

        reader.delegate = self;
        reader.beginSwipeWithMessage("Please swipe credit card");
    }

    public func readerCardResponse(card: CFTCard?, withError error: NSError?) {
        if let card = card {
            self.card = card;
            cardSwipedSignal.sendCompleted()

        } else if let error = error {
            cardSwipedSignal.sendError(error)
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