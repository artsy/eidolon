import UIKit
import SwiftyJSON

enum ReserveStatus: String {
    case ReserveNotMet = "reserve_not_met"
    case NoReserve = "no_reserve"
    case ReserveMet = "reserve_met"

    var reserveNotMet: Bool {
        return self == .ReserveNotMet
    }

    static func initOrDefault (_ rawValue: String?) -> ReserveStatus {
        return ReserveStatus(rawValue: rawValue ?? "") ?? .NoReserve
    }
}

final class SaleArtwork: NSObject, JSONAbleType {

    let id: String
    let artwork: Artwork
    let currencySymbol: String

    var auctionID: String?

    var saleHighestBid: Bid?
    dynamic var bidCount: NSNumber?

    var userBidderPosition: BidderPosition?
    var positions: [String]?

    var openingBidCents: NSNumber?
    var minimumNextBidCents: NSNumber?
    
    dynamic var highestBidCents: NSNumber?
    var estimateCents: Currency?
    var lowEstimateCents: Currency?
    var highEstimateCents: Currency?

    dynamic var reserveStatus: String?
    dynamic var lotLabel: NSString?

    init(id: String, artwork: Artwork, currencySymbol: String) {
        self.id = id
        self.artwork = artwork
        self.currencySymbol = currencySymbol
    }

    lazy var viewModel: SaleArtworkViewModel = {
        return SaleArtworkViewModel(saleArtwork: self)
    }()

    static func fromJSON(_ json: [String: Any]) -> SaleArtwork {
        let json = JSON(json)
        let id = json["id"].stringValue
        let currencySymbol = json["symbol"].stringValue

        let artworkDict = json["artwork"].object as! [String: AnyObject]
        let artwork = Artwork.fromJSON(artworkDict)

        let saleArtwork = SaleArtwork(id: id, artwork: artwork, currencySymbol: currencySymbol) as SaleArtwork

        if let highestBidDict = json["highest_bid"].object as? [String: AnyObject] {
            saleArtwork.saleHighestBid = Bid.fromJSON(highestBidDict)
        }

        saleArtwork.auctionID = json["sale_id"].string
        saleArtwork.openingBidCents = json["opening_bid_cents"].int as NSNumber?
        saleArtwork.minimumNextBidCents = json["minimum_next_bid_cents"].int as NSNumber?

        saleArtwork.highestBidCents = json["highest_bid_amount_cents"].int as NSNumber?
        saleArtwork.estimateCents = json["estimate_cents"].uInt64
        saleArtwork.lowEstimateCents = json["low_estimate_cents"].uInt64
        saleArtwork.highEstimateCents = json["high_estimate_cents"].uInt64
        saleArtwork.bidCount = json["bidder_positions_count"].int as NSNumber?
        saleArtwork.reserveStatus = json["reserve_status"].string
        saleArtwork.lotLabel = json["lot_label"].string as NSString?

        return saleArtwork
    }
    
    func updateWithValues(_ newSaleArtwork: SaleArtwork) {
        saleHighestBid = newSaleArtwork.saleHighestBid
        auctionID = newSaleArtwork.auctionID
        openingBidCents = newSaleArtwork.openingBidCents
        minimumNextBidCents = newSaleArtwork.minimumNextBidCents
        highestBidCents = newSaleArtwork.highestBidCents
        estimateCents = newSaleArtwork.estimateCents
        lowEstimateCents = newSaleArtwork.lowEstimateCents
        highEstimateCents = newSaleArtwork.highEstimateCents
        bidCount = newSaleArtwork.bidCount
        reserveStatus = newSaleArtwork.reserveStatus
        lotLabel = newSaleArtwork.lotLabel ?? lotLabel

        artwork.updateWithValues(newSaleArtwork.artwork)
    }
}

func ==(lhs: SaleArtwork, rhs: SaleArtwork) -> Bool {
    return lhs.id == rhs.id
}
