import Foundation

class Artist: JSONAble {

    let id: String
    dynamic var name: String
    let sortableID: String

    var blurb: String?

    init(id: String, name: String, sortableID: String) {
        self.id = id
        self.name = name
        self.sortableID = sortableID
    }

    override class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(json)

        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let sortableID = json["sortableID"].stringValue
        return Artist(id: id, name:name, sortableID:sortableID)
    }

}
