import UIKit

class PlaceBidNetworkModel: NSObject {

    var bidder:Bidder?
    var loggedInProvider:ReactiveMoyaProvider<ArtsyAPI>!

    func bidSignal(auctionID: String, bidDetails: BidDetails) -> RACSignal {

        let saleArtwork = bidDetails.saleArtwork
        let cents = String(bidDetails.bidAmountCents! as Int)

        var signal = RACSignal.empty().then {

            self.bidder == nil ? self.setBidderIfNeeded(auctionID) : RACSignal.empty()

        } .then {
            self.bidder == nil ? self.createBidderForAuction(auctionID) : RACSignal.empty()

        } .then {
            self.bidOnSaleArtwork(saleArtwork!, bidAmountCents: cents)

        }.catchTo(RACSignal.empty()).doError { [weak self] (error) -> Void in
            println("ERROR");
            return
        }

        return signal
    }

    func setBidderIfNeeded(auctionID: String) -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.MyBiddersForAuction(auctionID: auctionID)
        let request = loggedInProvider.request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Bidder.self)

        return request.doNext { [weak self] (bidders) -> Void in
            let bidders = bidders as [Bidder]
            self?.bidder = bidders.first

        }.doError({ [weak self] (error) -> Void in
            println("error, had issues with getting user bidders ")
            return
        })
    }

    func createBidderForAuction(auctionID: String) -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterToBid(auctionID: auctionID)
        let request = loggedInProvider.request(endpoint, method: .POST, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(Bidder.self)

        return request.doNext({ [weak self] (bidder) -> Void in
            self?.bidder = bidder as Bidder!
            return

        }).doError({ [weak self] (error) -> Void in
            println("error, had issues with registering a bidder ")
            return
        })
    }

    func bidOnSaleArtwork(saleArtwork: SaleArtwork, bidAmountCents: String) -> RACSignal {
        let bidEndpoint: ArtsyAPI = ArtsyAPI.PlaceABid(auctionID: saleArtwork.auctionID!, artworkID: saleArtwork.artwork.id, maxBidCents: bidAmountCents)

        let request = loggedInProvider.request(bidEndpoint, method: .POST, parameters:bidEndpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(BidderPosition.self)

        return request.doNext({ [weak self] (bidderPosition) -> Void in

            return

        }).doError({ [weak self] (error) -> Void in
            if let genericError = error.artsyServerError() {
                println("error, got: '\(genericError.message)' from API' ")
            }

            println("error, had issues with bidding ")
        })
    }

}
