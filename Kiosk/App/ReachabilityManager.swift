import UIKit
import Reachability
import ReactiveCocoa

public class ReachabilityManager: NSObject {
    public let reachSignal: RACSignal = RACReplaySubject(capacity: 1)
    
    private let reachability = Reachability.reachabilityForInternetConnection()

    public override init() {
        super.init()

        reachability.reachableBlock = { (_) in
            return (self.reachSignal as! RACSubject).sendNext(true)
        }

        reachability.unreachableBlock = { (_) in
            return (self.reachSignal as! RACSubject).sendNext(false)
        }

        reachability.startNotifier()
        (reachSignal as! RACSubject).sendNext(reachability.isReachable())
    }

    public func isReachable() -> Bool {
        return Reachability.reachabilityForInternetConnection().isReachable()
    }
}
