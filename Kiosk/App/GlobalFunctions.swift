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

// An observable that completes when the app gets online (possibly completes immediately).
func connectedToInternetOrStubbing() -> Observable<Bool> {
    let online = reachabilityManager.reach
    let stubbing = Observable.just(APIKeys.sharedKeys.stubResponses)

    return [online, stubbing].combineLatestOr()
}

func responseIsOK(response: Response) -> Bool {
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
    let _reach = ReplaySubject<Bool>.create(bufferSize: 1)
    var reach: Observable<Bool> {
        return _reach.asObservable()
    }

    private let reachability = Reachability.reachabilityForInternetConnection()

    override init() {
        super.init()

        reachability.reachableBlock = { [weak self] _ in
            dispatch_async(dispatch_get_main_queue()) {
                self?._reach.onNext(true)
            }
        }

        reachability.unreachableBlock = { [weak self] _ in
            dispatch_async(dispatch_get_main_queue()) {
                self?._reach.onNext(false)
            }
        }

        reachability.startNotifier()
        _reach.onNext(reachability.isReachable())
    }
}

func bindingErrorToInterface(error: ErrorType) {
    let error = "Binding error to UI: \(error)"
    #if DEBUG
        fatalError(error)
    #else
        print(error)
    #endif
}

// Applies an instance method to the instance with an unowned reference.
func applyUnowned<Type: AnyObject, Parameters, ReturnValue>(instance: Type, _ function: (Type -> Parameters -> ReturnValue)) -> (Parameters -> ReturnValue) {
    return { [unowned instance] parameters -> ReturnValue in
        return function(instance)(parameters)
    }
}
