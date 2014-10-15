import UIKit

class PlacingBidViewController: UIViewController {

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("P:2")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let auctionID = self.fulfilmentNav().auctionID!
        let bidDetails = self.fulfilmentNav().bidDetails
        bidDetailsPreviewView.bidDetails = bidDetails
        
        var signal = RACSignal.empty()
        signal = signal.then { [weak self] () in
            println("s:1")
            
            return self?.setBidderIfNeeded(auctionID) ?? RACSignal.empty()
            
            } .then { [weak self]() -> RACSignal! in
                println("s:2")
                return self?.createBidderForAuction(auctionID) ?? RACSignal.empty()
                
            } .then { [weak self]() -> RACSignal! in
                println("s:3")
                let saleArtwork = bidDetails.saleArtwork
                return self?.bidOnSaleArtwork(saleArtwork!, bidAmountCents: "\(bidDetails)") ?? RACSignal.empty()
        }
        
        signal.subscribeNext({ (bidder) -> Void in
            println("P:7")
        })

    }
    
    func setBidderIfNeeded(auctionID: String) -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.MyBiddersForAuction(auctionID: auctionID)
        let request = self.fulfilmentNav().loggedInProvider!.request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Bidder.self)
        
        return request.doNext { [weak self] (bidders) -> Void in
            let bidders = bidders as [Bidder]
            println("P:3")

            if countElements(bidders) == 0 { return }
            if let user = self?.fulfilmentNav().user! {
                println("P:4")
                user.bidder = bidders.first
            }
        
        }.doError({ [weak self] (error) -> Void in
            println("error, had issues with getting user bidders ")
            return
        })
    }
    
    func createBidderForAuction(auctionID: String) -> RACSignal? {
        if self.fulfilmentNav().user!.bidder != nil {
            println("P:5")
            return nil
        }
        
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterToBid(auctionID: auctionID)
        let request = self.fulfilmentNav().loggedInProvider!.request(endpoint, method: .POST, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(Bidder.self)

        return request.doNext({ [weak self] (bidder) -> Void in
            self!.fulfilmentNav().user!.bidder = bidder as Bidder!
            return
            
        }).doError({ [weak self] (error) -> Void in
            println("error, had issues with registering a bidder ")
            return
        })
    }
    
    func bidOnSaleArtwork(saleArtwork: SaleArtwork, bidAmountCents: String) -> RACSignal {
        let bidEndpoint: ArtsyAPI = ArtsyAPI.PlaceABid(auctionID: saleArtwork.auctionID!, artworkID: saleArtwork.artwork.id, maxBidCents: bidAmountCents)
        
        let request = self.fulfilmentNav().loggedInProvider!.request(bidEndpoint, method: .POST, parameters:bidEndpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(BidderPosition.self)
        
        return request.doNext({ [weak self] (bidderPosition) -> Void in
            println("P:6")
            return
            
        }).doError({ [weak self] (error) -> Void in
            if let genericError = error.artsyServerError() {
                println("error, got: '\(genericError.message)' from API' ")
            }
            
            println("error, had issues with bidding ")
            return
        })
    }
    
}
