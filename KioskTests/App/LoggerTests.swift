import Quick
import Nimble
import Kiosk

func logPath() -> NSURL {
    let docs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as NSURL
    return docs.URLByAppendingPathComponent("logger.txt")
}

class LoggerTests: QuickSpec {
    override func spec() {
        it("amends contents of logging file") {
            let testString = "Nobody has margaritas with pizza."
            let logger = Logger(destination: logPath())

            logger.log(testString)

            let fileContents = NSString(contentsOfURL: logPath(), encoding: NSUTF8StringEncoding, error: nil)

            expect(fileContents).to(contain(testString))
        }

        afterEach { () -> () in
            NSFileManager.defaultManager().removeItemAtURL(logPath(), error: nil)
            return
        }
    }
}
