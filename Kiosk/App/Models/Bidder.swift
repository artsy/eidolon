import UIKit

final class Bidder: NSObject, JSONAble {
    let id: String
    let saleID: String

    init(id: String, saleID: String) {
        self.id = id
        self.saleID = saleID
    }

    class func fromJSON(json:[String: AnyObject]) -> Bidder {
        let json = JSON(object: json)

        let id = json["id"].stringValue
        let saleID = json["sale"]["id"].stringValue
        return Bidder(id: id, saleID:saleID)
    }
}
