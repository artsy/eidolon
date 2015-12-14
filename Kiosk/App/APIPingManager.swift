import Foundation
import Moya
import RxSwift

class APIPingManager {

    let syncInterval: NSTimeInterval = 2
    var letOnline: Observable<Bool>!
    var provider: NetworkingType

    init(provider: NetworkingType) {
        self.provider = provider

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