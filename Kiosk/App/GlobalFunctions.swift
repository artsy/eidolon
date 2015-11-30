import RxSwift
import Reachability
import Moya

// Ideally a Pod. For now a file.
func delayToMainThread(delay:Double, closure:()->()) {
    dispatch_after (
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func logPath() -> NSURL {
    let docs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    return docs.URLByAppendingPathComponent("logger.txt")
}

let logger = Logger(destination: logPath())

private let reachabilityManager = ReachabilityManager()

// A signal that completes when the app gets online (possibly completes immediately).
func connectedToInternetOrStubbingSignal() -> Observable<Bool> {
    let online = reachabilityManager.reachSignal
    let stubbing = just(APIKeys.sharedKeys.stubResponses)

    return [online, stubbing].combineLatestOr()
}

func responseIsOK(response: MoyaResponse) -> Bool {
    return response.statusCode == 200
}


func detectDevelopmentEnvironment() -> Bool {
    var developmentEnvironment = false
    #if DEBUG || (arch(i386) || arch(x86_64)) && os(iOS)
        developmentEnvironment = true
    #endif
    return developmentEnvironment
}

private class ReachabilityManager: NSObject {
    let _reachSignal = ReplaySubject<Bool>.create(bufferSize: 1)
    var reachSignal: Observable<Bool> {
        return _reachSignal.asObservable()
    }

    private let reachability = Reachability.reachabilityForInternetConnection()

    override init() {
        super.init()

        reachability.reachableBlock = { [weak self] _ in
            self?._reachSignal.onNext(true)
        }

        reachability.unreachableBlock = { [weak self] _ in
            self?._reachSignal.onNext(true)
        }

        reachability.startNotifier()
        _reachSignal.onNext(reachability.isReachable())
    }
}

