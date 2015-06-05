import Foundation
import ISO8601DateFormatter
import ReactiveCocoa

public class SystemTime {
    public var systemTimeInterval: NSTimeInterval? = nil

    public init () {}

    public func syncSignal() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.SystemTime

        return XAppRequest(endpoint).filterSuccessfulStatusCodes().mapJSON()
            .doNext { [weak self] (response) -> Void in
                if let dictionary = response as? NSDictionary {
                    let formatter = ISO8601DateFormatter()

                    let artsyDate = formatter.dateFromString(dictionary["iso8601"] as! String?)
                    self?.systemTimeInterval = NSDate().timeIntervalSinceDate(artsyDate)
                }
                
            }.doError { (error) -> Void in
                logger.log("Error contacting Artsy servers: \(error.localizedDescription)")
            }
    }

    public func inSync() -> Bool {
        return systemTimeInterval != nil
    }

    public func date() -> NSDate {
        let now = NSDate()
        if let systemTimeInterval = systemTimeInterval {
            return now.dateByAddingTimeInterval(-systemTimeInterval)
        } else {
            return now
        }
    }

    public func reset() {
        systemTimeInterval = nil
    }
}
