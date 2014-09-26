import Foundation

final class Artist:NSObject, JSONAble {

    let id:String
    var name:String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    class func fromJSON(json:[String: AnyObject]) -> Artist {
        let json = JSON(object: json)

        let id = json["id"].stringValue
        let name = json["name"].stringValue

        return Artist(id: id, name:name)
    }

}
