import Foundation
import SwiftyJSON

public class Artist: JSONAble {

    public let id: String
    public dynamic var name: String
    public let sortableID: String?

    public var blurb: String?

    public init(id: String, name: String, sortableID: String?) {
        self.id = id
        self.name = name
        self.sortableID = sortableID
    }

    override public class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(json)

        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let sortableID = json["sortable_id"].string
        return Artist(id: id, name:name, sortableID:sortableID)
    }

}
