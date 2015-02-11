import UIKit
import ISO8601DateFormatter
import SwiftyJSON

public class Sale: JSONAble {
    public dynamic let id: String
    public dynamic let isAuction: Bool
    public dynamic let startDate: NSDate
    public dynamic let endDate: NSDate
    public dynamic let name: String
    public dynamic var artworkCount: Int
    public dynamic let auctionState: String

    public var buyersPremium: BuyersPremium?

    public init(id: String, name: String, isAuction: Bool, startDate: NSDate, endDate: NSDate, artworkCount: Int, state: String) {
        self.id = id
        self.name = name
        self.isAuction = isAuction
        self.startDate = startDate
        self.endDate = endDate
        self.artworkCount = artworkCount
        self.auctionState = state
    }

    override public class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(json)
        let formatter = ISO8601DateFormatter()

        let id = json["id"].stringValue
        let isAuction = json["is_auction"].boolValue
        let startDate = formatter.dateFromString(json["start_at"].stringValue)
        let endDate = formatter.dateFromString(json["end_at"].stringValue)
        let name = json["name"].stringValue
        let artworkCount = json["eligible_sale_artworks_count"].intValue
        let state = json["auction_state"].stringValue

        //// https://m.artsy.net/auction/[auction_id]/buyers-premium

        let sale = Sale(id: id, name:name, isAuction: isAuction, startDate: startDate, endDate: endDate, artworkCount: artworkCount, state: state)

        if let buyersPremiumDict = json["buyers_premium"].object as? [String: AnyObject] {
            sale.buyersPremium = BuyersPremium.fromJSON(buyersPremiumDict) as? BuyersPremium
        }

        return sale
    }

    public func isActive(systemTime:SystemTime) -> Bool {
        let now = systemTime.date()
        return now.earlierDate(startDate) == startDate && now.laterDate(endDate) == endDate
    }
}
