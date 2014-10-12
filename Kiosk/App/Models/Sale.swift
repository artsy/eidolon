import UIKit

class Sale: JSONAble {
    dynamic let id: String
    dynamic let isAuction:Bool
    dynamic let startDate:NSDate
    dynamic let endDate:NSDate

    init(id: String, isAuction: Bool, startDate: NSDate, endDate: NSDate) {
        self.id = id
        self.isAuction = isAuction
        self.startDate = startDate
        self.endDate = endDate
    }

    override class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(object: json)
        let formatter = ISO8601DateFormatter()

        let id = json["id"].stringValue
        let isAuction = json["is_auction"].boolValue
        let startDate = formatter.dateFromString(json["start_at"].stringValue)
        let endDate = formatter.dateFromString(json["end_at"].stringValue)
        return Sale(id: id, isAuction: isAuction, startDate: startDate, endDate: endDate)
    }

    func isActive(systemTime:SystemTime) -> Bool {
        let now = systemTime.date()
        return now.earlierDate(startDate) == startDate && now.laterDate(endDate) == endDate
    }
}
