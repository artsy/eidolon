import Foundation
import Moya
import RxSwift

class APIPingManager: NSObject {

    let syncInterval: NSTimeInterval = 2
    var letOnline: Observable<Bool>!
    // TODO: Inject this
    var provider: Provider!

    override init() {
        super.init()

        letOnline = interval(syncInterval, MainScheduler.sharedInstance)
            .flatMap { [weak self] _ in
                return self?.ping() ?? empty()
            }
            .startWith(true)
    }

    private func ping() -> Observable<Bool> {
        return provider.request(ArtsyAPI.Ping).map(responseIsOK)
    }
}