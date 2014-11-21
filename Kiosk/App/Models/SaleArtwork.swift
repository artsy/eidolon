import UIKit
import SwiftyJSON

public enum ReserveStatus {
    case NoReserve
    case ReserveNotMet
    case ReserveMet

    static func fromString(input: String?) -> ReserveStatus? {
        switch input {
        case .Some("reserve_not_met"):
            return ReserveNotMet
        case .Some("no_reserve"):
            return NoReserve
        case .Some("reserve_met"):
            return ReserveMet
        case .None:
            fallthrough
        default:
            return nil
        }
    }
}

public struct SaleNumberFormatter {
    static let dollarFormatter = createDollarFormatter()
}

public class SaleArtwork: JSONAble {

    public let id: String
    public let artwork: Artwork

    public var auctionID: String?

    // The bidder is given from JSON if user is registered
    public let bidder: Bidder?

    public var saleHighestBid: Bid?
    public dynamic var bidCount:  NSNumber?

    public var userBidderPosition: BidderPosition?
    public var positions: [String]?

    public dynamic var openingBidCents: NSNumber?
    public dynamic var minimumNextBidCents: NSNumber?
    
    public dynamic var highestBidCents: NSNumber?
    public var lowEstimateCents: Int?
    public var highEstimateCents: Int?

    public var reserveStatus: ReserveStatus = .NoReserve

    public var reserveNotMet: Bool {
        return self.reserveStatus == .ReserveNotMet
    }

    public init(id: String, artwork: Artwork) {
        self.id = id
        self.artwork = artwork
    }

    override public class func fromJSON(json: [String: AnyObject]) -> JSONAble {
        let json = JSON(json)
        let id = json["id"].stringValue
        let artworkDict = json["artwork"].object as [String: AnyObject]
        let artwork = Artwork.fromJSON(artworkDict) as Artwork

        let saleArtwork = SaleArtwork(id: id, artwork: artwork) as SaleArtwork

        if let highestBidDict = json["highest_bid"].object as? [String: AnyObject] {
            saleArtwork.saleHighestBid = Bid.fromJSON(highestBidDict) as? Bid
        }

        saleArtwork.auctionID = json["sale_id"].string
        saleArtwork.openingBidCents = json["opening_bid_cents"].int
        saleArtwork.minimumNextBidCents = json["minimum_next_bid_cents"].int

        saleArtwork.highestBidCents = json["highest_bid_amount_cents"].int
        saleArtwork.lowEstimateCents = json["low_estimate_cents"].int
        saleArtwork.highEstimateCents = json["high_estimate_cents"].int
        saleArtwork.bidCount = json["bidder_positions_count"].int
        saleArtwork.reserveStatus = ReserveStatus.fromString(json["reserve_status"].string) ?? .NoReserve

        return saleArtwork;
    }
    
    public func updateWithValues(newSaleArtwork: SaleArtwork) {
        saleHighestBid = newSaleArtwork.saleHighestBid
        auctionID = newSaleArtwork.auctionID
        openingBidCents = newSaleArtwork.openingBidCents
        minimumNextBidCents = newSaleArtwork.minimumNextBidCents
        highestBidCents = newSaleArtwork.highestBidCents
        lowEstimateCents = newSaleArtwork.lowEstimateCents
        highEstimateCents = newSaleArtwork.highEstimateCents
        bidCount = newSaleArtwork.bidCount
        reserveStatus = newSaleArtwork.reserveStatus
    }
    
    public var estimateString: String {
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

    public var numberOfBidsSignal: RACSignal {
        return RACObserve(self, "bidCount").map { (optionalBidCount) -> AnyObject! in
            // Technically, the bidCount is Int?, but the `as?` cast could fail (it never will, but the compiler doesn't know that)
            // So we need to unwrap it as an optional optional. Yo dawg.
            let bidCount = optionalBidCount as Int?

            if let bidCount = bidCount {
                let suffix = bidCount == 1 ? "" : "s"
                return "\(bidCount) bid\(suffix) placed"
            } else {
                return "0 bids placed"
            }
        }
    }

    public func currentBidSignal(prefix: String = "", missingPrefix: String = "") -> RACSignal {
        return RACObserve(self, "highestBidCents").map({ [weak self] (highestBidCents) -> AnyObject! in
            if let currentBidCents = highestBidCents as? Int {
                return "\(prefix)\(NSNumberFormatter.currencyStringForCents(currentBidCents))"
            } else {
                return "\(missingPrefix)\(NSNumberFormatter.currencyStringForCents(self?.openingBidCents ?? 0))"
            }
        })
    }

    override public class func keyPathsForValuesAffectingValueForKey(key: String) -> NSSet {
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