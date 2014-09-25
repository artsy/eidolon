import Foundation

class SystemTime {
    var systemTimeInterval:NSTimeInterval = NSTimeIntervalSince1970 as NSTimeInterval

    func sync() {
        let endpoint: ArtsyAPI = ArtsyAPI.SystemTime

        XAppRequest(endpoint).filterSuccessfulStatusCodes().mapJSON().subscribeNext({ (response) -> Void in
            if let dictionary = response as? NSDictionary {
                let formatter = ISO8601DateFormatter()

                let artsyDate = formatter.dateFromString(dictionary["iso8601"] as String?)
                self.systemTimeInterval = NSDate().timeIntervalSinceDate(artsyDate);
            }

        }, error: { (error) -> Void in
            println("Error: \(error.localizedDescription)")
        })
    }

    func inSync() -> Bool {
        return systemTimeInterval != NSTimeIntervalSince1970;
    }

    func date() -> NSDate {
        let now = NSDate()
        return self.inSync() ? now.dateByAddingTimeInterval(-systemTimeInterval) : now;
    }

    func reset() {
        self.systemTimeInterval = NSTimeIntervalSince1970
    }

}


