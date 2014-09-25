import Foundation

class SystemTime {
    var systemTimeInterval: NSTimeInterval? = nil

    func sync() {
        let endpoint: ArtsyAPI = ArtsyAPI.SystemTime

        XAppRequest(endpoint).filterSuccessfulStatusCodes().mapJSON().subscribeNext({ [weak self] (response) -> Void in
            if let dictionary = response as? NSDictionary {
                let formatter = ISO8601DateFormatter()

                let artsyDate = formatter.dateFromString(dictionary["iso8601"] as String?)
                self?.systemTimeInterval = NSDate().timeIntervalSinceDate(artsyDate)
            }

        }, error: { (error) -> Void in
            println("Error: \(error.localizedDescription)")
        })
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
        self.systemTimeInterval = nil
    }
}
