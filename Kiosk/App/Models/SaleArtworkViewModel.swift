import Foundation
import RxSwift

private let kNoBidsString = "0 bids placed"

class SaleArtworkViewModel: NSObject {
    private let saleArtwork: SaleArtwork

    init (saleArtwork: SaleArtwork) {
        self.saleArtwork = saleArtwork
    }
}

// Extension for computed properties

extension SaleArtworkViewModel {

    // MARK: Computed values we don't expect to ever change.

    var estimateString: String {
        // Default to estimateCents
        if let estimateCents = saleArtwork.estimateCents {
            let dollars = NSNumberFormatter.currencyStringForCents(estimateCents)
            return "Estimate: \(dollars)"
        }

        // Try to extract non-nil low/high estimates. Return a default otherwise.
        switch (saleArtwork.lowEstimateCents, saleArtwork.highEstimateCents) {
        case let (.Some(lowCents), .Some(highCents)):
            let lowDollars = NSNumberFormatter.currencyStringForCents(lowCents)
            let highDollars = NSNumberFormatter.currencyStringForCents(highCents)
            return "Estimate: \(lowDollars)–\(highDollars)"
        default:
            return "No Estimate"
        }
    }

    var thumbnailURL: NSURL? {
        return saleArtwork.artwork.defaultImage?.thumbnailURL()
    }

    var thumbnailAspectRatio: CGFloat? {
        return saleArtwork.artwork.defaultImage?.aspectRatio
    }

    var artistName: String? {
        return saleArtwork.artwork.artists?.first?.name
    }

    var titleAndDateAttributedString: NSAttributedString? {
        return saleArtwork.artwork.titleAndDate
    }

    var saleArtworkID: String {
        return saleArtwork.id
    }

    // Signals representing values that change over time.

    var numberOfBidsSignal: RACSignal {
        return RACObserve(saleArtwork, "bidCount").map { (optionalBidCount) -> AnyObject! in
            // Technically, the bidCount is Int?, but the `as?` cast could fail (it never will, but the compiler doesn't know that)
            // So we need to unwrap it as an optional optional. Yo dawg.
            let bidCount = optionalBidCount as! Int?

            if let bidCount = bidCount {
                let suffix = bidCount == 1 ? "" : "s"
                return "\(bidCount) bid\(suffix) placed"
            } else {
                return kNoBidsString
            }
        }
    }

    // The language used here is very specific – see https://github.com/artsy/eidolon/pull/325#issuecomment-64121996 for details
    var numberOfBidsWithReserveSignal: RACSignal {
        return RACSignal.combineLatest([numberOfBidsSignal, RACObserve(saleArtwork, "reserveStatus"), RACObserve(saleArtwork, "highestBidCents")]).map { (object) -> AnyObject! in
            let tuple = object as! RACTuple // Ignoring highestBidCents; only there to trigger on bid update.

            let numberOfBidsString = tuple.first as! String
            let reserveStatus = ReserveStatus.initOrDefault(tuple.second as? String)

            // if there is no reserve, just return the number of bids string.
            if reserveStatus == .NoReserve {
                return numberOfBidsString
            } else {
                if numberOfBidsString == kNoBidsString {
                    // If there are no bids, then return only this string.
                    return "This lot has a reserve"
                } else if reserveStatus == .ReserveNotMet {
                    return "(\(numberOfBidsString), Reserve not met)"
                } else { // implicitly, reserveStatus is .ReserveMet
                    return "(\(numberOfBidsString), Reserve met)"
                }
            }
        }
    }

    var lotNumberSignal: RACSignal {
        return RACObserve(saleArtwork, "lotNumber").map { (lotNumber) -> AnyObject! in
            if let lotNumber = lotNumber as? Int {
                return "Lot \(lotNumber)"
            } else {
                return nil
            }
        }.mapNilToEmptyString()
    }

    var forSaleSignal: RACSignal {
        return RACObserve(saleArtwork, "artwork").map { (artwork) -> AnyObject! in
            let artwork = artwork as! Artwork

            return Artwork.SoldStatus.fromString(artwork.soldStatus) == .NotSold
        }
    }

    func currentBidSignal(prefix prefix: String = "", missingPrefix: String = "") -> RACSignal {
        return RACObserve(saleArtwork, "highestBidCents").map { [weak self] (highestBidCents) -> AnyObject! in
            if let currentBidCents = highestBidCents as? Int {
                return "\(prefix)\(NSNumberFormatter.currencyStringForCents(currentBidCents))"
            } else {
                return "\(missingPrefix)\(NSNumberFormatter.currencyStringForCents(self?.saleArtwork.openingBidCents ?? 0))"
            }
        }
    }
}
