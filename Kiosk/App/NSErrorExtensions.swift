import Foundation
import Moya

extension NSError {

    func artsyServerError() -> NSString {
        if let errorJSON = userInfo["data"] as? [String: AnyObject] {
            let error =  GenericError.fromJSON(errorJSON)
            return "\(error.message) - \(error.detail) + \(error.detail)"
        } else if let response = userInfo["data"] as? Response {
            let stringData = NSString(data: response.data, encoding: NSUTF8StringEncoding)
            return "Status Code: \(response.statusCode), Data Length: \(response.data.length), String Data: \(stringData)"
        }

        return "\(userInfo)"
    }
}