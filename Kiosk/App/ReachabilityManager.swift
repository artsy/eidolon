import UIKit

class ReachabilityManager: NSObject {
    let reachSignal = RACSubject()
    let reachability = Reachability.reachabilityForInternetConnection()

    override init() {
        super.init()

        reachability.reachableBlock = { [weak self] (_) in
            self?.reachSignal.sendNext(true)
            return
        }

        reachability.unreachableBlock = { [weak self] (_) in
            self?.reachSignal.sendNext(false)
            return
        }

        reachability.startNotifier()
        reachSignal.sendNext(reachability.isReachable())
    }

    func isReachable() -> Bool {
        return reachability.isReachable()
    }
}
