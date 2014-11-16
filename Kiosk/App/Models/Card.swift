import Foundation
import SwiftyJSON

class Card: JSONAble {
    let id: String
    let name: String
    let lastDigits: String
    let expirationMonth: String
    let expirationYear: String

    init(id: String, name: String, lastDigits: String, expirationMonth: String, expirationYear: String) {

        self.id = id
        self.name = name
        self.lastDigits = lastDigits
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
    }

    override class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(json)

        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let lastDigits = json["last_digits"].stringValue
        let expirationMonth = json["expiration_month"].stringValue
        let expirationYear = json["expiration_year"].stringValue

        return Card(id: id, name: name, lastDigits: lastDigits, expirationMonth: expirationMonth, expirationYear: expirationYear)
    }

}
