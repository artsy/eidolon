import Foundation
import RxSwift

private let kNoBidsString = ""

class SaleArtworkViewModel: NSObject {
    fileprivate let saleArtwork: SaleArtwork

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
            let dollars = NumberFormatter.currencyString(forCents: estimateCents as NSNumber!)
            return "Estimate: \(dollars)"
        }

        // Try to extract non-nil low/high estimates. Return a default otherwise.
        switch (saleArtwork.lowEstimateCents, saleArtwork.highEstimateCents) {
        case let (.some(lowCents), .some(highCents)):
            let lowDollars = NumberFormatter.currencyString(forCents: lowCents as NSNumber!)
            let highDollars = NumberFormatter.currencyString(forCents: highCents as NSNumber!)
            return "Estimate: \(lowDollars)–\(highDollars)"
        default:
            return "No Estimate"
        }
    }

    var thumbnailURL: URL? {
        return saleArtwork.artwork.defaultImage?.thumbnailURL() as URL?
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

    // Observables representing values that change over time.

    func numberOfBids() -> Observable<String> {
        return saleArtwork.rx.observe(NSNumber.self, "bidCount").map { optionalBidCount -> String in
            guard let bidCount = optionalBidCount , bidCount.intValue > 0 else {
                return kNoBidsString
            }
            
            let suffix = bidCount == 1 ? "" : "s"
            return "\(bidCount) bid\(suffix) placed"
        }
    }

    // The language used here is very specific – see https://github.com/artsy/eidolon/pull/325#issuecomment-64121996 for details
    var numberOfBidsWithReserve: Observable<String> {

        // Ignoring highestBidCents; only there to trigger on bid update.
        let highestBidString = saleArtwork.rx.observe(NSNumber.self, "highestBidCents").map { "\($0)" }
        let reserveStatus = saleArtwork.rx.observe(String.self, "reserveStatus").map { input -> String in
            switch input {
            case .some(let reserveStatus):
                return reserveStatus
            default:
                return ""
            }
        }

        return [numberOfBids(), reserveStatus, highestBidString].combineLatest { strings -> String in

            let numberOfBidsString = strings[0]
            let reserveStatus = ReserveStatus.initOrDefault(strings[1])

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

    func lotNumber() -> Observable<String?> {
        return saleArtwork.rx.observe(NSNumber.self, "lotNumber").map { lotNumber  in
            if let lotNumber = lotNumber as? Int {
                return "Lot \(lotNumber)"
            } else {
                return ""
            }
        }
    }

    func forSale() -> Observable<Bool> {
        return saleArtwork.artwork.rx.observe(String.self, "soldStatus").filterNil().map { status in
            return Artwork.SoldStatus.fromString(status) == .notSold
        }

    }

    func currentBid(prefix: String = "", missingPrefix: String = "") -> Observable<String> {
        return saleArtwork.rx.observe(NSNumber.self, "highestBidCents").map { [weak self] highestBidCents in
            if let currentBidCents = highestBidCents as? Int {
                return "\(prefix)\(NumberFormatter.currencyString(forCents: currentBidCents as NSNumber!))"
            } else {
                return "\(missingPrefix)\(NumberFormatter.currencyString(forCents: self?.saleArtwork.openingBidCents ?? 0))"
            }
        }
    }

    func currentBidOrOpeningBid() -> Observable<String> {
        let observables = [
            saleArtwork.rx.observe(NSNumber.self, "bidCount"),
            saleArtwork.rx.observe(NSNumber.self, "openingBidCents"),
            saleArtwork.rx.observe(NSNumber.self, "highestBidCents")
        ]

        return observables.combineLatest { numbers -> Int in
            let bidCount = (numbers[0] ?? 0) as Int
            let openingBid = numbers[1] as Int?
            let highestBid = numbers[2] as Int?

            return (bidCount > 0 ? highestBid : openingBid) ?? 0
        }.map(centsToPresentableDollarsString)
    }

    func currentBidOrOpeningBidLabel() -> Observable<String> {
        return saleArtwork.rx.observe(NSNumber.self, "bidCount").map { input in
            guard let count = input as? Int else { return "" }

            if count > 0 {
                return "Current Bid:"
            } else {
                return "Opening Bid:"
            }
        }
    }
}
