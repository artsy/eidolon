protocol JSONAbleType {
    static func fromJSON(_: [String: AnyObject]) -> Self
}
