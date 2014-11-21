import UIKit
import Artsy_UILabels
import ARAnalytics

public class LoadingViewController: UIViewController {

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    @IBOutlet weak var statusMessage: ARSerifLabel!
    @IBOutlet weak var spinner: Spinner!
    @IBOutlet weak var bidConfirmationImageView: UIImageView!

    public var placingBid = true

    public var performNetworking = true
    public var animate = true

    public var bidderNetworkModel: BidderNetworkModel!
    public var bidCheckingModel: BidCheckingNetworkModel!
    public var placeBidNetworkModel: PlaceBidNetworkModel!
    public var details: BidDetails?

    @IBOutlet public weak var backToAuctionButton: SecondaryActionButton!
    @IBOutlet public weak var placeHigherBidButton: ActionButton!

    func bidDetails() -> BidDetails {
        return details ?? self.fulfillmentNav().bidDetails
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if placingBid  {
            bidDetailsPreviewView.bidDetails = bidDetails()
        } else {
            bidDetailsPreviewView.hidden = true
        }

        statusMessage.hidden = true
        backToAuctionButton.hidden = true
        placeHigherBidButton.hidden = true

        spinner.animate(animate)

        titleLabel.text = placingBid ? "Placing bid..." : "Registering..."

        bidderNetworkModel = bidderNetworkModel ?? BidderNetworkModel()
        bidderNetworkModel.fulfillmentNav = fulfillmentNav()

        if !performNetworking { return }

        bidderNetworkModel.createOrGetBidder().doError { (error) -> Void in
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

            self?.bidCheckingModel = self?.bidCheckingModel ?? self?.createBidCheckingModel()
            if self?.placingBid == false { return RACSignal.empty() }

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
        placeBidNetworkModel = placeBidNetworkModel ?? PlaceBidNetworkModel()
        let auctionID = self.fulfillmentNav().auctionID!
        placeBidNetworkModel.fulfillmentNav = self.fulfillmentNav()

        return placeBidNetworkModel.bidSignal(bidDetails()).doError { (_) in
            self.bidPlacementFailed()
        }
    }

    func finishUp() {
        self.spinner.hidden = true
        let reserveNotMet = bidCheckingModel.reserveNotMet
        let isHighestBidder = bidCheckingModel.isHighestBidder
        let bidIsResolved = bidCheckingModel.bidIsResolved
        let createdNewBidder = bidderNetworkModel.createdNewBidder

        if placingBid {
            ARAnalytics.event("Placed a bid", withProperties: ["top_bidder" : isHighestBidder])

            if bidIsResolved {

                if reserveNotMet {
                    handleReserveNotMet()
                } else if isHighestBidder {
                    handleHighestBidder()
                } else {
                    handleLowestBidder()
                }

            } else {
                handleUnknownBidder()
            }

        } else if createdNewBidder {
            handleRegistered()
        }

        let showPlaceHigherButton = placingBid && (!isHighestBidder || reserveNotMet)
        placeHigherBidButton.hidden = !showPlaceHigherButton

        let showAuctionButton = !placingBid || createdNewBidder
        backToAuctionButton.hidden = !showAuctionButton

        let title = createdNewBidder ? "CONTINUE" : "BACK TO AUCTION"
        backToAuctionButton.setTitle(title, forState: .Normal)
    }

    func handleRegistered() {
        titleLabel.text = "Registration Complete"
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")
    }

    func handleUnknownBidder() {
        titleLabel.text = "Bid Confirmed"
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")
    }

    func handleReserveNotMet() {
        titleLabel.text = "Reserve Not Met"
        statusMessage.hidden = false
        // TODO: improve this message
        statusMessage.text = "Please place another bid."
        bidConfirmationImageView.image = UIImage(named: "BidNotHighestBidder")
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

    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .PushtoBidConfirmed {
            let detailsVC = segue.destinationViewController as YourBiddingDetailsViewController
            detailsVC.confirmationImage = bidConfirmationImageView.image
            detailsVC.hidePreview = bidDetailsPreviewView.hidden
            detailsVC.registered = bidderNetworkModel.createdNewBidder
            detailsVC.isHighestBidder = bidCheckingModel.isHighestBidder
        }

        if segue == .PlaceaHigherBidAfterNotBeingHighestBidder {
            let placeBidVC = segue.destinationViewController as PlaceBidViewController
            placeBidVC.hasAlreadyPlacedABid = true
        }
    }

    @IBAction func placeHigherBidTapped(sender: AnyObject) {
        self.fulfillmentNav().bidDetails.bidAmountCents = 0
        self.performSegue(.PlaceaHigherBidAfterNotBeingHighestBidder)
    }

    @IBAction func backToAuctionTapped(sender: AnyObject) {
        if bidderNetworkModel.createdNewBidder {
            self.performSegue(.PushtoBidConfirmed)
        } else {
            fulfillmentContainer()?.closeFulfillmentModal()
        }
    }
}
