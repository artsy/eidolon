import Foundation

extension NSError {

    func artsyServerError() -> GenericError? {
        if let errorJSON = self.userInfo?["data"] as? [String: AnyObject] {
            return GenericError.fromJSON(errorJSON) as? GenericError
        }
        return nil
    }
}