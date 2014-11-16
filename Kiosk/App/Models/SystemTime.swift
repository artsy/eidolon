import Foundation
import ISO8601DateFormatter

class SystemTime {
    var systemTimeInterval: NSTimeInterval? = nil

    func syncSignal() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.SystemTime

        return XAppRequest(endpoint).filterSuccessfulStatusCodes().mapJSON()
            .doNext { [weak self] (response) -> Void in
                if let dictionary = response as? NSDictionary {
                    let formatter = ISO8601DateFormatter()

                    let artsyDate = formatter.dateFromString(dictionary["iso8601"] as String?)
                    self?.systemTimeInterval = NSDate().timeIntervalSinceDate(artsyDate)
                }
                
            }.doError { (error) -> Void in
                println("Error: \(error.localizedDescription)")
            }
    }

    func inSync() -> Bool {
        return systemTimeInterval != nil
    }

    func date() -> NSDate {
        let now = NSDate()
        if let systemTimeInterval = systemTimeInterval {
            return now.dateByAddingTimeInterval(-systemTimeInterval)
        } else {
            return now
        }
    }

    func reset() {
        systemTimeInterval = nil
    }
}
