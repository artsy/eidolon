import Foundation
import Moya

/// Logs network activity (outgoing requests and incoming responses).
class NetworkLogger<Target: MoyaTarget>: Plugin<Target> {

    typealias Comparison = Target -> Bool

    let whitelist: Comparison
    let blacklist: Comparison

    init(whitelist: Comparison = { _ -> Bool in return true }, blacklist: Comparison = { _ -> Bool in  return true }) {
        self.whitelist = whitelist
        self.blacklist = blacklist

        super.init()
    }

    override func willSendRequest(request: MoyaRequest, provider: MoyaProvider<Target>, target: Target) {
        // If the target is in the blacklist, don't log it.
        guard blacklist(target) == false else { return }
        logger.log("Sending request: \(request.request?.URL?.absoluteString ?? String())")
    }

    override func didReceiveResponse(data: NSData?, statusCode: Int?, response: NSURLResponse?, error: ErrorType?, provider: MoyaProvider<Target>, target: Target) {
        // If the target is in the blacklist, don't log it.
        guard blacklist(target) == false else { return }

        if 200..<400 ~= (statusCode ?? 0) && whitelist(target) == false {
            // If the status code is OK, and if it's not in our whitelist, then don't worry about logging its response body.
            logger.log("Received response(\(statusCode ?? 0)) from \(response?.URL?.absoluteString ?? String()).")
        } else {
            // Otherwise, log everything.

            let dataString: NSString?
            if let data = data {
                dataString = NSString(data: data, encoding: NSUTF8StringEncoding) ?? "Encoding error"
            } else {
                dataString = "No response body"
            }

            logger.log("Received response(\(statusCode ?? 0)) from \(response?.URL?.absoluteString ?? String()): \(dataString)")
        }
    }
}
