import Foundation
import SwiftyJSON

public class Bid: JSONAble {
    public let id: String
    public let amountCents: Int

    init(id: String, amountCents: Int) {
        self.id = id
        self.amountCents = amountCents
    }

    override public class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(json)

        let id = json["id"].stringValue
        let amount = json["amount_cents"].int
        return Bid(id: id, amountCents: amount!)
    }
}
