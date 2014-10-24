import UIKit

class Bidder: JSONAble {
    let id: String
    let saleID: String
    var pin: String?

    init(id: String, saleID: String, pin: String?) {
        self.id = id
        self.saleID = saleID
        self.pin = pin
    }

    override class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(json)
        println(json.description)
        let id = json["id"].stringValue
        let saleID = json["sale"]["id"].stringValue
        let pin = json["pin"].stringValue
        return Bidder(id: id, saleID: saleID, pin: pin)
    }
}
