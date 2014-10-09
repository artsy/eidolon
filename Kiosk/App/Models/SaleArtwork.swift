import UIKit

enum ReserveStatus {
    case NoReserve
    case ReserveNotMet(Int)
    case ReserveMet
}

struct SaleNumberFormatter {
    static let dollarFormatter = createDollarFormatter()
}

class SaleArtwork: JSONAble {

    let id: String
    let artwork: Artwork

    var auctionID: String?

    // The bidder is given from JSON if user is registered
    let bidder: Bidder?

    var saleHighestBid: Bid?
    dynamic var bidCount:  NSNumber?

    var userBidderPosition: BidderPosition?
    var positions: [String]?

    dynamic var openingBidCents: NSNumber?
    dynamic var minimumNextBidCents: NSNumber?
    
    dynamic var highestBidCents: NSNumber?
    var lowEstimateCents: Int?
    var highEstimateCents: Int?

    init(id: String, artwork: Artwork) {
        self.id = id
        self.artwork = artwork
    }

    override class func fromJSON(json: [String: AnyObject]) -> JSONAble {
        let json = JSON(object: json)

        let id = json["id"].stringValue
        let artworkDict = json["artwork"].object as [String: AnyObject]
        let artwork = Artwork.fromJSON(artworkDict) as Artwork

        let saleArtwork = SaleArtwork(id: id, artwork: artwork) as SaleArtwork

        if let highestBidDict = json["highest_bid"].object as? [String: AnyObject] {
            saleArtwork.saleHighestBid = Bid.fromJSON(highestBidDict) as? Bid
        }

        saleArtwork.auctionID = json["sale_id"].string
        saleArtwork.openingBidCents = json["opening_bid_cents"].integer
        saleArtwork.minimumNextBidCents = json["minimum_next_bid_cents"].integer

        saleArtwork.highestBidCents = json["highest_bid_amount_cents"].integer
        saleArtwork.lowEstimateCents = json["low_estimate_cents"].integer
        saleArtwork.highEstimateCents = json["high_estimate_cents"].integer
        saleArtwork.bidCount = json["bidder_positions_count"].integer
//        let reserveStatus = json["reserve_status"].integer

        return saleArtwork;
    }
    
    var estimateString: String {
        switch (lowEstimateCents, highEstimateCents) {
        case let (.Some(lowCents), .Some(highCents)):
            let lowDollars = NSNumberFormatter.currencyStringForCents(lowCents)
            let highDollars = NSNumberFormatter.currencyStringForCents(highCents)
            return "Estimate: \(lowDollars)–\(highDollars)"
        case let (.Some(lowCents), nil):
            let lowDollars = NSNumberFormatter.currencyStringForCents(lowCents)
            return "Estimate: \(lowDollars)"
        case let (nil, .Some(highCents)):
            let highDollars = NSNumberFormatter.currencyStringForCents(highCents)
            return "Estimate: \(highDollars)"
        default:
            return "No Estimate"
        }
    }
    
    override class func keyPathsForValuesAffectingValueForKey(key: String) -> NSSet {
        if key == "estimateString" {
            return NSSet(array: ["lowEstimateCents", "highEstimateCents"])
        } else {
            return super.keyPathsForValuesAffectingValueForKey(key)
        }
    }
}

func createDollarFormatter() -> NSNumberFormatter {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle

    // This is always dollars, so let's make sure that's how it shows up
    // regardless of locale.

    formatter.currencyGroupingSeparator = ","
    formatter.currencySymbol = "$"
    formatter.maximumFractionDigits = 0
    return formatter
}