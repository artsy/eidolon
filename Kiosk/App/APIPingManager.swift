import Foundation
import Moya
import RxSwift

class APIPingManager {

    let syncInterval: NSTimeInterval = 2
    var letOnline: Observable<Bool>!
    var provider: Networking

    init(provider: Networking) {
        self.provider = provider

        letOnline = Observable<Int>.interval(syncInterval, scheduler: MainScheduler.instance)
            .flatMap { [weak self] _ in
                return self?.ping() ?? .empty()
            }
            .startWith(true)
    }

    private func ping() -> Observable<Bool> {
        return provider.request(ArtsyAPI.Ping).map(responseIsOK)
    }
}