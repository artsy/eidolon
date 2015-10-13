import Foundation
import Moya

/// Logs network activity (outgoing requests and incoming responses).
class NetworkLogger<Target: MoyaTarget>: Plugin<Target> {

    override func willSendRequest(request: MoyaRequest, provider: MoyaProvider<Target>, target: Target) {
        logger.log("Sending request: \(request.request?.URL?.absoluteString)")
    }

    override func didReceiveResponse(data: NSData?, statusCode: Int?, response: NSURLResponse?, error: ErrorType?, provider: MoyaProvider<Target>, target: Target) {
        let dataString: NSString?
        if let data = data {
            dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
        } else {
            dataString = "No response body"
        }
        logger.log("Received response(\(statusCode) from \(response?.URL?.absoluteString): \(dataString)")
    }
}
