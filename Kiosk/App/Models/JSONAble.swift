protocol JSONAble: NSObjectProtocol {
    class func fromJSON([String:AnyObject]) -> Self
}
