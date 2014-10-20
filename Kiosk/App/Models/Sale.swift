import UIKit

class Sale: JSONAble {
    dynamic let id: String
    dynamic let isAuction: Bool
    dynamic let startDate: NSDate
    dynamic let endDate: NSDate
    dynamic let name: String
    dynamic var artworkCount: Int

    init(id: String, name: String, isAuction: Bool, startDate: NSDate, endDate: NSDate, artworkCount: Int) {
        self.id = id
        self.name = name
        self.isAuction = isAuction
        self.startDate = startDate
        self.endDate = endDate
        self.artworkCount = artworkCount
    }

    override class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(json)
        let formatter = ISO8601DateFormatter()

        let id = json["id"].stringValue
        let isAuction = json["is_auction"].boolValue
        let startDate = formatter.dateFromString(json["start_at"].stringValue)
        let endDate = formatter.dateFromString(json["end_at"].stringValue)
        let name = json["name"].stringValue
        let artworkCount = json["eligible_sale_artworks_count"].intValue

        return Sale(id: id, name:name, isAuction: isAuction, startDate: startDate, endDate: endDate, artworkCount: artworkCount)
    }

    func isActive(systemTime:SystemTime) -> Bool {
        let now = systemTime.date()
        return now.earlierDate(startDate) == startDate && now.laterDate(endDate) == endDate
    }
}
