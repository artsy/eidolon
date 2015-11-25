import Foundation
import Moya
import RxSwift

class APIPingManager: NSObject {

    let syncInterval: NSTimeInterval = 2
    var letOnlineSignal: Observable<Bool>!

    override init() {
        super.init()

        letOnlineSignal = interval(syncInterval, MainScheduler.sharedInstance)
            .flatMap { [weak self] _ in
                return self?.pingSignal() ?? empty()
            }
            .startWith(true)
    }

    private func pingSignal() -> Observable<Bool> {
        return XAppRequest(ArtsyAPI.Ping).map(responseIsOK)
    }
}