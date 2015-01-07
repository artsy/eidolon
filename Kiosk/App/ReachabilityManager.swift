import UIKit
import Reachability
import ReactiveCocoa

class ReachabilityManager: NSObject {
    let reachSignal:RACSignal = RACReplaySubject(capacity: 1)
    private let reachability = Reachability.reachabilityForInternetConnection()

    override init() {
        super.init()

        reachability.reachableBlock = { (_) in
            return (self.reachSignal as RACSubject).sendNext(true)
        }

        reachability.unreachableBlock = { (_) in
            return (self.reachSignal as RACSubject).sendNext(false)
        }

        reachability.startNotifier()
        (reachSignal as RACSubject).sendNext(reachability.isReachable())
    }

    func isReachable() -> Bool {
        return Reachability.reachabilityForInternetConnection().isReachable()
    }
}
