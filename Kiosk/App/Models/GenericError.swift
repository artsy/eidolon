import Foundation
import SwiftyJSON

final class GenericError: NSObject, JSONAbleType {
    let detail: [String:AnyObject]
    let message: String
    let type: String
    
    init(type: String, message: String, detail: [String:AnyObject]) {
        self.detail = detail
        self.message = message
        self.type = type
    }
    
    static func fromJSON(json:[String: AnyObject]) -> GenericError {
        let json = JSON(json)
        
        let type = json["type"].stringValue
        let message = json["message"].stringValue
        var detailDictionary = json["detail"].object as? [String: AnyObject]
        
        detailDictionary = detailDictionary ?? [:]
        return GenericError(type: type, message: message, detail: detailDictionary!)
    }
}
