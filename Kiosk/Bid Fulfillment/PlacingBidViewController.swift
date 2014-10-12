import UIKit

class PlacingBidViewController: UIViewController {

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("P:2")
        
        let auctionID = self.fulfilmentNav().auctionID!
        let bidDetails = self.fulfilmentNav().bidDetails
        bidDetailsPreviewView.bidDetails = bidDetails
        
        self.setBidderIfNeeded(auctionID).then({ [weak self] () -> RACSignal! in

            return self?.createBidderForAuction(auctionID) ?? RACSignal.empty()
            
        }).then({ [weak self]() -> RACSignal! in
            
            let saleArtwork = bidDetails.saleArtwork!
            return self?.bidOnSaleArtwork(saleArtwork, bidAmountCents: "\(bidDetails.bidAmountCents)")

        }).subscribeNext({ (bidder) -> Void in
            println("P:7")
        })
    }
    
    func setBidderIfNeeded(auctionID: String) -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.MyBiddersForAuction(auctionID: auctionID)
        let request = self.fulfilmentNav().loggedInProvider!.request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Bidder.self)
        
        request.subscribeNext({ [weak self] (bidders) -> Void in
            let bidders = bidders as [Bidder]
            println("P:3")

            if countElements(bidders) > 0 { return }
            if let user = self?.fulfilmentNav().user! {
                println("P:4")
                user.bidder = bidders.first
            }
        })
        
        request.doError({ [weak self] (error) -> Void in
            println("error, had issues with getting user bidders ")
            return
        })
        
        return request
    }
    
    func createBidderForAuction(auctionID: String) -> RACSignal? {
        if self.fulfilmentNav().user!.bidder != nil {
            println("P:5")
            return nil
        }
        
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterToBid(auctionID: auctionID)
        let request = self.fulfilmentNav().loggedInProvider.request(endpoint, method: .POST, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(Bidder.self)

        request.subscribeNext({ [weak self] (bidder) -> Void in
            self?.fulfilmentNav().user?.bidder = bidder as? Bidder
            return
        })

        request.doError({ [weak self] (error) -> Void in
            println("error, had issues with registering a bidder ")
            return
        })
        
        return request
    }
    
    func bidOnSaleArtwork(saleArtwork: SaleArtwork, bidAmountCents: String) -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.PlaceABid(auctionID: saleArtwork.auctionID!, artworkID: saleArtwork.artwork.id, maxBidCents: bidAmountCents)
        
        let request = self.fulfilmentNav().loggedInProvider.request(endpoint, method: .POST, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(SaleArtwork.self)
        
        request.subscribeNext({ [weak self] (updatedSaleArtwork) -> Void in
            println("P:6")
            return
        })
        
        request.doError({ [weak self] (error) -> Void in
            if let genericError = error.artsyServerError() {
                println("error, got: '\(genericError.message)' from API' ")
            }
            
            println("error, had issues with bidding ")
            return
        })
        
        return request
    }
    
}
