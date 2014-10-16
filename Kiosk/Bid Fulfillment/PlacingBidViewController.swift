import UIKit

class PlacingBidViewController: UIViewController {

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let auctionID = self.fulfillmentNav().auctionID!
        let bidDetails = self.fulfillmentNav().bidDetails

        bidDetailsPreviewView.bidDetails = bidDetails
        
        var signal:RACSignal = self.setBidderIfNeeded(auctionID) ?? RACSignal.empty()
        signal = signal.then {

            return self.createBidderForAuction(auctionID) ?? RACSignal.empty()
                
        } .then {

            let saleArtwork = bidDetails.saleArtwork
            let cents = String(bidDetails.bidAmountCents! as Int)
            return self.bidOnSaleArtwork(saleArtwork!, bidAmountCents: cents)

        }.catchTo(RACSignal.empty()).doError { [weak self] (error) -> Void in
            println("ERROR");
            return
        }
        
        signal.subscribeNext { [weak self] (_) in
            self?.performSegue(.PushtoBidConfirmed)
            return
        }

    }
    
    func setBidderIfNeeded(auctionID: String) -> RACSignal {
        if self.fulfillmentNav().user.bidder != nil { return RACSignal.empty() }

        let endpoint: ArtsyAPI = ArtsyAPI.MyBiddersForAuction(auctionID: auctionID)
        let request = self.fulfillmentNav().loggedInProvider!.request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Bidder.self)
        
        return request.doNext { [weak self] (bidders) -> Void in
            let bidders = bidders as [Bidder]

            if let user = self?.fulfillmentNav().user! {
                user.bidder = bidders.first
            }
        
        }.doError({ [weak self] (error) -> Void in
            println("error, had issues with getting user bidders ")
            return
        })
    }

    func createBidderForAuction(auctionID: String) -> RACSignal {
        if self.fulfillmentNav().user!.bidder != nil { return RACSignal.empty() }

        let endpoint: ArtsyAPI = ArtsyAPI.RegisterToBid(auctionID: auctionID)
        let request = self.fulfillmentNav().loggedInProvider!.request(endpoint, method: .POST, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(Bidder.self)

        return request.doNext({ [weak self] (bidder) -> Void in
            self!.fulfillmentNav().user!.bidder = bidder as Bidder!
            return
            
        }).doError({ [weak self] (error) -> Void in
            println("error, had issues with registering a bidder ")
            return
        })
    }
    
    func bidOnSaleArtwork(saleArtwork: SaleArtwork, bidAmountCents: String) -> RACSignal {
        let bidEndpoint: ArtsyAPI = ArtsyAPI.PlaceABid(auctionID: saleArtwork.auctionID!, artworkID: saleArtwork.artwork.id, maxBidCents: bidAmountCents)
        
        let request = self.fulfillmentNav().loggedInProvider!.request(bidEndpoint, method: .POST, parameters:bidEndpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(BidderPosition.self)
        
        return request.doNext({ [weak self] (bidderPosition) -> Void in
            println("P:6")
            return
            
        }).doError({ [weak self] (error) -> Void in
            if let genericError = error.artsyServerError() {
                println("error, got: '\(genericError.message)' from API' ")
            }
            
            println("error, had issues with bidding ")
        })
    }
    
}
