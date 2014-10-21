import UIKit

class PlacingBidViewController: UIViewController {

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    @IBOutlet weak var outbidNoticeLabel: ARSerifLabel!
    @IBOutlet weak var spinner: Spinner!
    @IBOutlet weak var bidConfirmationImageView: UIImageView!

    let placeBidNetworkModel = PlaceBidNetworkModel()
    var registerNetworkModel: RegistrationNetworkModel?
    var foundHighestBidder = false
    
    var pollInterval = NSTimeInterval(1)
    var maxPollRequests = 6
    
    var pollRequests = 0

    @IBOutlet weak var backToAuctionButton: ActionButton!

    // for comparisons at the end
    var bidderPositions:[BidderPosition]?
    var mostRecentSaleArtwork:SaleArtwork?

    override func viewDidLoad() {
        super.viewDidLoad()

        outbidNoticeLabel.hidden = true
        backToAuctionButton.hidden = true

        let auctionID = self.fulfillmentNav().auctionID!
        let bidDetails = self.fulfillmentNav().bidDetails

        bidDetailsPreviewView.bidDetails = bidDetails

        RACSignal.empty().then {
            self.registerNetworkModel == nil ? RACSignal.empty() : self.registerNetworkModel?.registerSignal()

        } .then {
            self.placeBidNetworkModel.fulfillmentNav = self.fulfillmentNav()
            return self.placeBidNetworkModel.bidSignal(auctionID, bidDetails:bidDetails)

        } .doError { (error) -> Void in
            self.outbidNoticeLabel.text = "There was a problem placing your bid, please talk to your nearest Artsy rep."
            self.outbidNoticeLabel.hidden = false

        }.subscribeNext { [weak self] (_) in
            self?.startCheckingForMaxBid()
            return
        }

    }

    func startCheckingForMaxBid() {
        // We delay to give the server some time to do the auction
        // 0.5 may be a tad excessive, but on the whole the networking for
        // register / bidding is probably about 2-3 seconds, so another 0.5
        // isn't gonna hurt so much.

        self.pollForUpdatedSaleArtwork().then { [weak self] () -> RACSignal! in
            self?.getMyBidderPositions().doNext { [weak self] (newBidderPositions) -> Void in
                
                let newBidderPositions = newBidderPositions as? [BidderPosition]
                self?.bidderPositions = newBidderPositions
                
            } ?? RACSignal.empty()
        }.doError { [weak self] (error) -> Void in
            self?.outbidNoticeLabel.text = "There was a problem placing your bid, please talk to your nearest Artsy rep."
            self?.outbidNoticeLabel.hidden = false

        }.subscribeNext { [weak self] (_) -> Void in
            self?.finishUp()
            return
        }
    }

    func finishUp() {
        self.spinner.hidden = true

        if let topBidderID = mostRecentSaleArtwork?.saleHighestBid?.id {
            for position in bidderPositions! {
                if position.highestBid?.id == topBidderID {
                    foundHighestBidder = true
                }
            }
        }

        if (foundHighestBidder) {
            isHighestBidder()
        } else {
            isLowestBidder()
        }
        
        // Update the bid details sale artwork to our mostRecentSaleArtwork
        if let mostRecentSaleArtwork = self.mostRecentSaleArtwork {
            let bidDetails = self.fulfillmentNav().bidDetails
            bidDetails.saleArtwork?.updateWithValues(mostRecentSaleArtwork)
        }

        let showBidderDetails = hasCreatedAUser() || !foundHighestBidder
        if showBidderDetails {
            backToAuctionButton.hidden = true

            let delayTime = foundHighestBidder ? 3.0 : 7.0
            delayToMainThread(delayTime) {
                self.performSegue(.PushtoBidConfirmed)
            }
        }
    }

    func hasCreatedAUser() -> Bool {
        return registerNetworkModel != nil
    }

    func isHighestBidder() {
        titleLabel.text = "Bid Confirmed"
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")
    }

    func isLowestBidder() {
        titleLabel.text = "Higher bid needed"
        titleLabel.textColor = UIColor.artsyRed()
        outbidNoticeLabel.hidden = false
        bidConfirmationImageView.image = UIImage(named: "BidNotHighestBidder")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .PushtoBidConfirmed {
            let registrationConfirmationVC = segue.destinationViewController as YourBiddingDetailsViewController
            registrationConfirmationVC.titleText = titleLabel.text
            registrationConfirmationVC.titleColor = titleLabel.textColor
            registrationConfirmationVC.confirmationImage = bidConfirmationImageView.image

            let highestBidCopy = "You will be asked for your Bidder Number and PIN next time you bid instead of entering all your information."
            let notHighestBidderCopy = "Use your Bidder Number and PIN next time you bid."
            registrationConfirmationVC.bodyCopy = foundHighestBidder ? highestBidCopy : notHighestBidderCopy
        }
    }
    
    func pollForUpdatedSaleArtwork() -> RACSignal {
        
        func getUpdatedSaleArtwork() -> RACSignal {
            
            let nav = self.fulfillmentNav()
            let artworkID = nav.bidDetails.saleArtwork!.artwork.id;
            
            let endpoint: ArtsyAPI = ArtsyAPI.AuctionInfoForArtwork(auctionID: nav.auctionID, artworkID: artworkID)
            return nav.loggedInProvider!.request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(SaleArtwork.self)
        }
        
        let beginningBidCents = self.fulfillmentNav().bidDetails.saleArtwork?.saleHighestBid?.amountCents ?? 0
        
        let updatedSaleArtworkSignal = getUpdatedSaleArtwork().flattenMap { [weak self] (saleObject) -> RACStream! in
            println("Polling \(self?.pollRequests) of \(self?.maxPollRequests) for updated sale artwork")
            
            self?.pollRequests++
            let sale = saleObject as? SaleArtwork
            
            let updatedBidCents = sale?.saleHighestBid?.amountCents ?? 0
            if  updatedBidCents != beginningBidCents {
                // This is an updated model – hooray!
                self?.mostRecentSaleArtwork = sale
                return RACSignal.empty()
            } else {
                if (self?.pollRequests ?? 0) >= (self?.maxPollRequests ?? 0) {
                    // We have exceeded our max number of polls, fail.
                    return RACSignal.error(nil)
                } else {
                    // We didn't get an updated value, so let's try again.
                    return RACSignal.empty().delay(self?.pollInterval ?? 1).then({ () -> RACSignal! in
                        return self?.pollForUpdatedSaleArtwork()
                    })
                }
            }
        }
        
        return RACSignal.empty().delay(pollInterval).then { updatedSaleArtworkSignal }
    }

    func getMyBidderPositions() -> RACSignal {
        let nav = self.fulfillmentNav()
        let artworkID = nav.bidDetails.saleArtwork!.artwork.id;

        let endpoint: ArtsyAPI = ArtsyAPI.MyBidPositionsForAuctionArtwork(auctionID: nav.auctionID, artworkID: artworkID)
        return nav.loggedInProvider!.request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(BidderPosition.self)
    }

    @IBAction func backToAuctionTapped(sender: AnyObject) {
        self.fulfillmentNav().parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func delayToMainThread(delay:Double, closure:()->()) {
        dispatch_after (
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
