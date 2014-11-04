import Foundation

class APIPingManager: NSObject {

    let syncInterval: NSTimeInterval = 2
    let letOnlineSignal: RACSignal!

    override init() {
        super.init()

        let recurringSignal = RACSignal.interval(syncInterval, onScheduler: RACScheduler.mainThreadScheduler()).startWith(NSDate()).takeUntil(rac_willDeallocSignal())

        letOnlineSignal = recurringSignal.map { [weak self] (_) -> AnyObject! in
            return self?.pingSignal() ?? RACSignal.empty()
        }.switchToLatest()
    }

    private func pingSignal() -> RACSignal {
        let artworksEndpoint: ArtsyAPI = ArtsyAPI.Ping
        return XAppRequest(artworksEndpoint).map { (object) -> AnyObject! in
            if let response = object as? MoyaResponse {
                return response.statusCode == 200
            }
            return false
        }.catchTo(RACSignal.`return`(false))
    }
}