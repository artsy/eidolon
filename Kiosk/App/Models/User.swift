import Foundation

class User: JSONAble {

    dynamic let id: String
    dynamic let email: String
    dynamic let name: String
    dynamic let paddleNumber: String
    dynamic let phoneNumber: String
    dynamic let postalCode: String
    dynamic var bidder: Bidder?

    init(id: String, email: String, name: String, paddleNumber: String, phoneNumber: String, postalCode: String) {
        self.id = id
        self.name = name
        self.paddleNumber = paddleNumber
        self.email = email
        self.phoneNumber = phoneNumber
        self.postalCode = postalCode
    }
    
    override class func fromJSON(json: [String: AnyObject]) -> JSONAble {
        let json = JSON(object: json)
        
        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let email = json["email"].stringValue
        let paddleNumber = json["paddle_number"].stringValue
        let phoneNumber = json["phone"].stringValue
        let postalCode = json["postal_code"].stringValue
        
        return User(id: id, email: email, name: name, paddleNumber: paddleNumber, phoneNumber: phoneNumber, postalCode: postalCode)
    }
}
