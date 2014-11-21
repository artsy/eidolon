import UIKit
import SwiftyJSON

public class Bidder: JSONAble {
    public let id: String
    public let saleID: String
    public var pin: String?

    init(id: String, saleID: String, pin: String?) {
        self.id = id
        self.saleID = saleID
        self.pin = pin
    }

    override public class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(json)

        let id = json["id"].stringValue
        let saleID = json["sale"]["id"].stringValue
        let pin = json["pin"].stringValue
        return Bidder(id: id, saleID: saleID, pin: pin)
    }
}
