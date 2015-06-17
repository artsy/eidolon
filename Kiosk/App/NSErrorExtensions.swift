import Foundation

extension NSError {

    func artsyServerError() -> NSString {
        if let errorJSON = self.userInfo?["data"] as? [String: AnyObject] {
            let error =  GenericError.fromJSON(errorJSON) as! GenericError
            return "\(error.message) - \(error.detail) + \(error.detail)"
        }
        return ""
    }
}