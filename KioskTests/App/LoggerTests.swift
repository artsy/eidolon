import Quick
import Nimble
@testable
import Kiosk

func logPath() -> URL {
    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    return docs!.appendingPathComponent("logger.txt")
}

class LoggerTests: QuickSpec {
    override func spec() {
        it("amends contents of logging file") {
            let testString = "Nobody has margaritas with pizza."
            let logger = Logger(destination: logPath())

            logger.log(testString)

            let fileContents = try! String(contentsOf: logPath(), encoding: .utf8)

            expect(fileContents).to(contain(testString))
        }

        afterEach {
            try! FileManager.default.removeItem(at: logPath())
            return
        }
    }
}
