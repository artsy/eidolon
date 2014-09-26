import Foundation

final class Bid: NSObject, JSONAble {
    let id:String
    let amountCents:Int

    init(id: String, amountCents: Int) {
        self.id = id
        self.amountCents = amountCents
    }

    class func fromJSON(json:[String: AnyObject]) -> Bid {
        let json = JSON(object: json)

        let id = json["id"].stringValue
        let amount = json["amount_cents"].integerValue
        return Bid(id: id, amountCents: amount)
    }
}
