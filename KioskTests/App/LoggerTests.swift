import Quick
import Nimble
@testable
import Kiosk

func logPath() -> NSURL {
    let docs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
    return docs!.URLByAppendingPathComponent("logger.txt")
}

class LoggerTests: QuickSpec {
    override func spec() {
        it("amends contents of logging file") {
            let testString = "Nobody has margaritas with pizza."
            let logger = Logger(destination: logPath())

            logger.log(testString)

            let fileContents = try! NSString(contentsOfURL: logPath(), encoding: NSUTF8StringEncoding)

            expect(fileContents).to(contain(testString))
        }

        afterEach {
            try! NSFileManager.defaultManager().removeItemAtURL(logPath())
            return
        }
    }
}
