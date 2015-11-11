import Foundation
import Moya
import ReactiveCocoa

class APIPingManager: NSObject {

    let syncInterval: NSTimeInterval = 2
    var letOnlineSignal: RACSignal!

    override init() {
        super.init()

        let recurringSignal = RACSignal.interval(syncInterval, onScheduler: RACScheduler.mainThreadScheduler()).startWith(NSDate()).takeUntil(rac_willDeallocSignal())

        letOnlineSignal = recurringSignal.map { [weak self] (_) -> AnyObject! in
            return self?.pingSignal() ?? RACSignal.empty()
        }.switchToLatest().startWith(true)
    }

    private func pingSignal() -> RACSignal {
        let artworksEndpoint: ArtsyAPI = ArtsyAPI.Ping
        return XAppRequest(artworksEndpoint).map(responseIsOK)
    }
}