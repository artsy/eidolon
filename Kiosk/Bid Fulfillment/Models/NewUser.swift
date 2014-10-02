@objc class NewUser: NSObject {
    dynamic var username:String?
    dynamic var password:String?
    dynamic var phoneNumber:String?

    init(username: String?, password: String?, phoneNumber:String?) {
        self.username = username
        self.password = password
        self.phoneNumber = phoneNumber
    }

}