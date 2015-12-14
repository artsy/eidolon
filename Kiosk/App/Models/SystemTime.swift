import Foundation
import ISO8601DateFormatter
import RxSwift

class SystemTime {
    var systemTimeInterval: NSTimeInterval? = nil

    init () {}

    func sync(provider: ProviderType) -> Observable<Void> {
        let endpoint: ArtsyAPI = ArtsyAPI.SystemTime

        return provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .doOnNext { [weak self] response in
                guard let dictionary = response as? NSDictionary else { return }
                let formatter = ISO8601DateFormatter()

                let artsyDate = formatter.dateFromString(dictionary["iso8601"] as! String?)
                self?.systemTimeInterval = NSDate().timeIntervalSinceDate(artsyDate)

            }.logError().map(void)
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
