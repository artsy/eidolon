@objc class NewUser: NSObject {
    dynamic var email:String?
    dynamic var password:String?
    dynamic var phoneNumber:String?

    init(email: String?, password: String?, phoneNumber:String?) {
        self.email = email
        self.password = password
        self.phoneNumber = phoneNumber
    }

}