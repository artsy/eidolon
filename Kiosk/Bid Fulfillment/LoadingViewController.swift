import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    @IBOutlet weak var statusMessage: ARSerifLabel!
    @IBOutlet weak var spinner: Spinner!
    @IBOutlet weak var bidConfirmationImageView: UIImageView!

    var placingBid = true
    var bidderNetworkModel: BidderNetworkModel!
    var bidCheckingModel: BidCheckingNetworkModel!

    @IBOutlet weak var backToAuctionButton: ActionButton!

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

        bidderNetworkModel = bidderNetworkModel ?? BidderNetworkModel()
        bidderNetworkModel.fulfillmentNav = fulfillmentNav()

        self.bidderNetworkModel.createOrGetBidder().doError { (error) -> Void in
            self.bidderError()

        } .then {
            if !self.placingBid {
                ARAnalytics.event("Registered New User Only")
                return RACSignal.empty()
            }

            ARAnalytics.event("Started Placing Bid")
            return self.placeBid()

        } .then { [weak self] (_) in
            if self == nil { return RACSignal.empty() }

            self?.bidCheckingModel = self?.createBidCheckingModel()
            return self!.bidCheckingModel.waitForBidResolution()

        } .subscribeCompleted { [weak self] (_) in
            self?.finishUp()
            return
        }
    }

    func createBidCheckingModel() -> BidCheckingNetworkModel {
        let nav = fulfillmentNav()
        return BidCheckingNetworkModel(details: nav.bidDetails, provider: nav.loggedInProvider!)
    }

    func placeBid() -> RACSignal {
        let placeBidNetworkModel = PlaceBidNetworkModel()
        let auctionID = self.fulfillmentNav().auctionID!
        placeBidNetworkModel.fulfillmentNav = self.fulfillmentNav()

        return placeBidNetworkModel.bidSignal(bidDetails()).doError { (_) in
            self.bidPlacementFailed()
        }
    }

    func finishUp() {
        self.spinner.hidden = true
        let isHighestBidder = bidCheckingModel.isHighestBidder
        let bidIsResolved = bidCheckingModel.bidIsResolved

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

    // MARK: - Error Handling

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

    @IBAction func backToAuctionTapped(sender: AnyObject) {
        fulfillmentContainer()?.closeFulfillmentModal()
    }
}
