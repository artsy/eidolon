import Foundation

public class Logger {
    public let destination: NSURL
    lazy private var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        return formatter
    }()
    lazy private var fileHandle: NSFileHandle? = {
        if let path = self.destination.path {
            NSFileManager.defaultManager().createFileAtPath(path, contents: nil, attributes: nil)
            var error: NSError?

            if let fileHandle = try? NSFileHandle(forWritingToURL: self.destination) {
                print("Successfully logging to: \(path)")
                return fileHandle
            } else {
                print("Serious error in logging: could not open path to log file. \(error).")
            }
        } else {
            print("Serious error in logging: specified destination (\(self.destination)) does not appear to have a path component.")
        }

        return nil
    }()

    public init(destination: NSURL) {
        self.destination = destination
    }

    deinit {
        fileHandle?.closeFile()
    }

    public func log(message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__) {
        let logMessage = stringRepresentation(message, function: function, file: file, line: line)

        printToConsole(logMessage)
        printToDestination(logMessage)
    }
}

private extension Logger {
    func stringRepresentation(message: String, function: String, file: String, line: Int) -> String {
        let dateString = dateFormatter.stringFromDate(NSDate())

        return "\(dateString) [\(NSURL(fileURLWithPath: file).lastPathComponent):\(line)] \(function): \(message)\n"
    }

    func printToConsole(logMessage: String) {
        print(logMessage)
    }

    func printToDestination(logMessage: String) {
        if let data = logMessage.dataUsingEncoding(NSUTF8StringEncoding) {
            fileHandle?.writeData(data)
        } else {
            print("Serious error in logging: could not encode logged string into data.")
        }
    }
}
