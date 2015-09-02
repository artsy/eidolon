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

// Adapted from https://github.com/FUKUZAWA-Tadashi/FHCCommander/blob/67c67757ee418a106e0ce0c0820459299b3d77bb/fhcc/Convenience.swift#L33-L44
func getSSID() -> String? {
    let interfaces: CFArray! = CNCopySupportedInterfaces()
    if interfaces == nil { return nil }

    let if0: UnsafePointer<Void>? = CFArrayGetValueAtIndex(interfaces, 0)
    if if0 == nil { return nil }

    let interfaceName: CFStringRef = unsafeBitCast(if0!, CFStringRef.self)
    let dictionary = CNCopyCurrentNetworkInfo(interfaceName) as NSDictionary?
    if dictionary == nil { return nil }

    return dictionary?[kCNNetworkInfoKeySSID as String] as? String
}

func detectDevelopment() -> Bool {
    var developmentEnvironment = false
    #if (arch(i386) || arch(x86_64)) && os(iOS)
        developmentEnvironment = true
        #else
        developmentEnvironment = getSSID()?.lowercaseString.containsString("artsy") ?? false
    #endif
    return developmentEnvironment
}
