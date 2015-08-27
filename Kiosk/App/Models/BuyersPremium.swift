import UIKit
import SwiftyJSON

class BuyersPremium: JSONAble {
    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    override class func fromJSON(json: [String: AnyObject]) -> JSONAble {
        let json = JSON(json)
        let id = json["id"].stringValue
        let name = json["name"].stringValue

        return BuyersPremium(id: id, name: name)
    }
}
