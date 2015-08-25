import ReactiveCocoa
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

let reachabilityManager = ReachabilityManager()

// A signal that completes when the app gets online (possibly completes immediately).
func connectedToInternetSignal() -> RACSignal {
    return reachabilityManager.reachSignal.filter { ($0 as! Bool) }.take(1).ignoreValues()
}

func responseIsOK(object: AnyObject!) -> AnyObject {
    if let response = object as? MoyaResponse {
        return response.statusCode == 200
    }
    return false
}
