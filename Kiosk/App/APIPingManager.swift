import Foundation
import Moya
import RxSwift

class APIPingManager: NSObject {

    let syncInterval: NSTimeInterval = 2
    var letOnline: Observable<Bool>!

    override init() {
        super.init()

        letOnline = interval(syncInterval, MainScheduler.sharedInstance)
            .flatMap { [weak self] _ in
                return self?.ping() ?? empty()
            }
            .startWith(true)
    }

    private func ping() -> Observable<Bool> {
        return XAppRequest(ArtsyAPI.Ping).map(responseIsOK)
    }
}