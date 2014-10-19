import Foundation

class Bid: JSONAble {
    let id: String
    let amountCents: Int

    init(id: String, amountCents: Int) {
        self.id = id
        self.amountCents = amountCents
    }

    override class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(json)

        let id = json["id"].stringValue
        let amount = json["amount_cents"].int
        return Bid(id: id, amountCents: amount!)
    }
}
