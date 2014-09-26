import UIKit

final class Sale: NSObject, JSONAble {
    let id: String
    let isAuction:Bool
    let startDate:NSDate
    let endDate:NSDate

    init(id: String, isAuction: Bool, startDate: NSDate, endDate: NSDate) {
        self.id = id
        self.isAuction = isAuction
        self.startDate = startDate
        self.endDate = endDate
    }

    class func fromJSON(json:[String: AnyObject]) -> Sale {
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
