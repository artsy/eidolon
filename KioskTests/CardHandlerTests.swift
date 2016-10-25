import Quick
import Nimble
@testable
import Kiosk
import RxSwift

class CardHandlerTests: QuickSpec {
    var handler: CardHandler!
    var reader: LocalCardReader!

    override func spec() {
        let apiKey = "jhfbsdhbfsd"
        let accountToken = "dxcvxfvdfgvxcv"

        var disposeBag: DisposeBag!

        beforeEach {
            let manager = CFTSessionManager()
            self.reader = LocalCardReader()

            self.handler = CardHandler(apiKey: apiKey, accountToken: accountToken)

            self.handler.reader = self.reader!
            self.handler.sessionManager = manager

            disposeBag = DisposeBag()
        }

        pending("sets up the Cardflight API + Token") {
            expect(self.handler.sessionManager.apiToken()) == apiKey
            expect(self.handler.sessionManager.accountToken()) == accountToken
        }

        xit("sends an observable with a card if successful") {
            var success = false
            self.handler
                .cardStatus
                .subscribe(onCompleted: { input in
                    success = true
                })
                .addDisposableTo(disposeBag)

            self.handler.startSearching()
            expect(success) == true
        }

        xit("sends an observable with an error if failed") {
            self.reader.fail = true

            var failed = false
            self.handler
                .cardStatus
                .subscribe(onError: { _ in
                    failed = true
                })
                .addDisposableTo(disposeBag)

            self.handler!.startSearching()
            expect(failed) == true
        }

        xit("passes messages along the card observable as things are moving") {
            var messageCount = 0

            self.handler!
                .cardStatus
                .subscribe(onNext: { (message) in
                    messageCount = messageCount + 1
                })
                .addDisposableTo(disposeBag)

            self.handler!.readerIsAttached()
            self.handler!.readerIsConnecting()
            self.handler!.readerIsDisconnected()
            self.handler!.readerSwipeDidCancel()
            self.handler!.readerGenericResponse("string")

            expect(messageCount) == 5
        }

    }
}

class LocalCardReader: CFTReader {
    var fail = false

    override func beginSwipe() {
        if fail {
            let error = NSError(domain: "eidolon", code: 111, userInfo: nil)
            self.delegate?.readerCardResponse!(nil, withError: error)

        } else {
            self.delegate?.readerCardResponse!(CFTCard(), withError: nil)
        }
    }
}
