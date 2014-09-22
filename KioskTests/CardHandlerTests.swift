import Quick
import Nimble
import Kiosk

class CardHandlerTests: QuickSpec {
    var handler:CardHandler?
    var reader:LocalCardReader?

    override func spec() {
        let apiKey = "jhfbsdhbfsd"
        let accountToken = "dxcvxfvdfgvxcv"

        beforeEach({
            var manager = CFTSessionManager()
            self.reader = LocalCardReader()

            self.handler = CardHandler(apiKey: apiKey, accountToken: accountToken)

            self.handler!.reader = self.reader!
            self.handler!.sessionManager = manager
        })

        it("sets up the Cardflight API + Token") {
            self.handler!.startSearching()

            expect(self.handler!.sessionManager.getApiToken()) == apiKey
            expect(self.handler!.sessionManager.getAccountToken()) == accountToken
        }

        it("sends a signal with a card if successful") {
            var success = false
            self.handler!.cardSwipedSignal.subscribeCompleted({ input -> Void in
                success = true
            })

            self.handler!.startSearching()
            expect(success) == true
        }

        it("sends a signal with a error if failed") {
            self.reader?.fail = true

            var success = false
            self.handler?.cardSwipedSignal.subscribeError({ input -> Void in
                success = true
            })

            self.handler!.startSearching()
            expect(success) == true
        }

        it("passes messages along the card signal as things are moving") {
            var messageCount = 0

            self.handler!.cardSwipedSignal.subscribeNext({ (message) -> Void in
                messageCount = messageCount + 1
            })

            self.handler!.readerIsAttached()
            self.handler!.readerIsConnecting()
            self.handler!.readerIsDisconnected()
            self.handler!.readerSwipeDidCancel()
            self.handler!.readerGenericResponse("string")

            expect(messageCount) == 5
        }

    }
}
