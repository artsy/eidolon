import UIKit

class CardHandler: NSObject, CFTReaderDelegate {

    let cardSwipedSignal = RACSubject()
    var card: CFTCard?
    
    let APIKey: String
    let APIToken: String

    lazy var reader = CFTReader(andConnect: ())
    lazy var sessionManager = CFTSessionManager.sharedInstance()

    init(apiKey: String, accountToken: String){
        APIKey = apiKey
        APIToken = accountToken
        super.init()
    }

    func startSearching() {
        sessionManager.setApiToken(APIKey, accountToken: APIToken)
        sessionManager.setLogging(true)
        
        reader.delegate = self;
    }
    
    func readerCardResponse(card: CFTCard?, withError error: NSError?) {
        if let card = card {
            self.card = card;
            cardSwipedSignal.sendNext("Got Card")
            
            card.tokenizeCardWithSuccess({ [unowned self] () -> Void in
                self.cardSwipedSignal.sendCompleted()
                
            }, failure: { [unowned self]  (error) -> Void in

            })
            
        } else if let error = error {

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
    }

    func readerSwipeDidCancel() {
        cardSwipedSignal.sendNext("Reader did disconnect");
    }

    func readerGenericResponse(cardData: String!) {
        cardSwipedSignal.sendNext("Reader received non-card data: \(cardData) ");
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
            self.delegate.readerCardResponse(nil, withError: error)

        } else {
            self.delegate.readerCardResponse(CFTCard(), withError: nil)
        }
    }
}