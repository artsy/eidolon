import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    @IBOutlet weak var statusMessage: ARSerifLabel!
    @IBOutlet weak var spinner: Spinner!
    @IBOutlet weak var bidConfirmationImageView: UIImageView!

    var placingBid = true
    var bidIsResolved = false
    var isHighestBidder = false

    var bidderNetworkModel: BidderNetworkModel!

    var pollInterval = NSTimeInterval(1)
    var maxPollRequests = 6

    var pollRequests = 0

    @IBOutlet weak var backToAuctionButton: ActionButton!

    // for comparisons at the end
    var mostRecentSaleArtwork:SaleArtwork?

    func bidDetails() -> BidDetails {
        return self.fulfillmentNav().bidDetails
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if placingBid  {
            bidDetailsPreviewView.bidDetails = bidDetails()
        } else {
            bidDetailsPreviewView.hidden = true
        }

        statusMessage.hidden = true
        backToAuctionButton.hidden = true

        titleLabel.text = placingBid ? "Placing bid..." : "Registering..."


        if self.bidderNetworkModel? == nil { // Case when user was not in the registration flow.
            self.bidderNetworkModel = BidderNetworkModel()
            self.bidderNetworkModel.fulfillmentNav = self.fulfillmentNav()
        }

        self.bidderNetworkModel.createOrGetBidder().doError { (error) -> Void in
            self.bidderError()
        } .then {
            if !self.placingBid {
                ARAnalytics.event("Registered New User Only")
                return RACSignal.empty()
            }

            ARAnalytics.event("Started Placing Bid")
            return self.placeBid().doError { (error) -> Void in
                self.bidPlacementFailed()
            } .then { [weak self] (_) in
                if self == nil { return RACSignal.empty() }
                return self!.waitForBidResolution().doNext { _ in
                    self?.bidIsResolved = true
                    return
                } .catchTo( RACSignal.empty() ) // If polling fails, we can still show you a bid confirmation. Do not error.
            }

        } .subscribeCompleted { [weak self] (_) -> Void in
            self?.finishUp()
            return
        }
    }

    // Error Handling

    func bidderError() {
        if placingBid {
            // If you are bidding, we show a bidding error regardless of whether or not you're also registering.
            bidPlacementFailed()
        } else {
            // If you're not placing a bid, you're here because you're just registering.
            presentError("Registration Failed", message: "There was a problem registering for the auction. Please speak to an Artsy representative.")
        }
    }

    func bidPlacementFailed() {
        presentError("Bid Failed", message: "There was a problem placing your bid. Please speak to an Artsy representative.")
    }

    func presentError(title: String, message: String) {
        spinner.hidden = true
        titleLabel.textColor = UIColor.artsyRed()
        titleLabel.text = title
        statusMessage.text = message
        statusMessage.hidden = false
    }

    func placeBid() -> RACSignal {
        let placeBidNetworkModel = PlaceBidNetworkModel()
        let auctionID = self.fulfillmentNav().auctionID!
        placeBidNetworkModel.fulfillmentNav = self.fulfillmentNav()
        return placeBidNetworkModel.bidSignal(bidDetails())
    }

    func waitForBidResolution () -> RACSignal {
        // We delay to give the server some time to do the auction
        // 0.5 may be a tad excessive, but on the whole the networking for
        // register / bidding is probably about 2-3 seconds, so another 0.5
        // isn't gonna hurt so much.

        return self.pollForUpdatedSaleArtwork().then { [weak self] (_) in
            return self == nil ? RACSignal.empty() : self!.checkForMaxBid()

        }
    }

    func checkForMaxBid() -> RACSignal {
        return self.getMyBidderPositions().doNext { [weak self] (newBidderPositions) -> Void in
            let newBidderPositions = newBidderPositions as? [BidderPosition]
            if let topBidID = self?.mostRecentSaleArtwork?.saleHighestBid?.id {
                for position in newBidderPositions! {
                    if position.highestBid?.id == topBidID {
                        self?.isHighestBidder = true
                    }
                }
            } else {
                RACSignal.error(nil)
            }
        }
    }

    func finishUp() {
        self.spinner.hidden = true

        if placingBid {
            ARAnalytics.event("Placed a bid", withProperties: ["top_bidder" : isHighestBidder])

            if bidIsResolved {

                if (isHighestBidder) {
                    handleHighestBidder()

                } else {
                    handleLowestBidder()
                }

            } else {
                handleUnknownBidder()
            }

        } else if bidderNetworkModel.createdNewBidder {
            handleRegistered()
        }

        let delayTime = bidIsResolved ? 7.0 : 3.0

        delayToMainThread(delayTime) {
            self.performSegue(.PushtoBidConfirmed)
        }
    }

    func handleRegistered() {
        titleLabel.text = "Registration Complete"
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")
    }

    func handleUnknownBidder() {
        titleLabel.text = "Bid Confirmed"
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")
    }

    func handleHighestBidder() {
        titleLabel.text = "High Bid!"
        statusMessage.hidden = false
        // TODO: improve this message
        statusMessage.text = "You are are the high bidder for this lot."
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")
    }

    func handleLowestBidder() {
        titleLabel.text = "Higher bid needed"
        titleLabel.textColor = UIColor.artsyRed()
        statusMessage.hidden = false
        statusMessage.text = "Another bidder has placed a higher maximum bid. Place a higher bid to secure the lot."
        bidConfirmationImageView.image = UIImage(named: "BidNotHighestBidder")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .PushtoBidConfirmed {
            let detailsVC = segue.destinationViewController as YourBiddingDetailsViewController
            detailsVC.titleText = titleLabel.text
            detailsVC.titleColor = titleLabel.textColor
            detailsVC.confirmationImage = bidConfirmationImageView.image
            detailsVC.hidePreview = bidDetailsPreviewView.hidden
            detailsVC.registered = bidderNetworkModel.createdNewBidder
        }
    }

    func pollForUpdatedSaleArtwork() -> RACSignal {

        func getUpdatedSaleArtwork() -> RACSignal {

            let nav = self.fulfillmentNav()
            let artworkID = bidDetails().saleArtwork!.artwork.id;

            let endpoint: ArtsyAPI = ArtsyAPI.AuctionInfoForArtwork(auctionID: nav.auctionID, artworkID: artworkID)
            return nav.loggedInProvider!.request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(SaleArtwork.self)
        }

        let beginningBidCents = bidDetails().saleArtwork?.saleHighestBid?.amountCents ?? 0

        let updatedSaleArtworkSignal = getUpdatedSaleArtwork().flattenMap { [weak self] (saleObject) -> RACStream! in
            self?.pollRequests++
            println("Polling \(self?.pollRequests) of \(self?.maxPollRequests) for updated sale artwork")

            let saleArtwork = saleObject as? SaleArtwork

            let updatedBidCents = saleArtwork?.saleHighestBid?.amountCents ?? 0

            // TODO: handle the case where the user was already the highest bidder
            if  updatedBidCents != beginningBidCents {
                // This is an updated model – hooray!
                if let saleArtwork = saleArtwork {
                    self?.mostRecentSaleArtwork = saleArtwork
                    self?.bidDetails().saleArtwork?.updateWithValues(saleArtwork)
                }
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
        let artworkID = bidDetails().saleArtwork!.artwork.id;

        let endpoint: ArtsyAPI = ArtsyAPI.MyBidPositionsForAuctionArtwork(auctionID: nav.auctionID, artworkID: artworkID)
        return nav.loggedInProvider!.request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(BidderPosition.self)
    }

    // Go Back

    @IBAction func backToAuctionTapped(sender: AnyObject) {
        fulfillmentContainer()?.closeFulfillmentModal()
    }
}
