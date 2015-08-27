import UIKit
import Artsy_UILabels
import ARAnalytics
import ReactiveCocoa
import Swift_RAC_Macros

class LoadingViewController: UIViewController {

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    @IBOutlet weak var statusMessage: ARSerifLabel!
    @IBOutlet weak var spinner: Spinner!
    @IBOutlet weak var bidConfirmationImageView: UIImageView!

    var placingBid = true

    var animate = true

    @IBOutlet weak var backToAuctionButton: SecondaryActionButton!
    @IBOutlet weak var placeHigherBidButton: ActionButton!

    lazy var viewModel: LoadingViewModel = { () -> LoadingViewModel in
        return LoadingViewModel(bidNetworkModel: BidderNetworkModel(fulfillmentController: self.fulfillmentNav()), placingBid: self.placingBid)
    }()

    lazy var recognizer = UITapGestureRecognizer()
    lazy var closeSelf: () -> Void = { [weak self] in
        self?.fulfillmentContainer()?.closeFulfillmentModal()
        return
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if placingBid  {
            bidDetailsPreviewView.bidDetails = viewModel.bidDetails
        } else {
            bidDetailsPreviewView.hidden = true
        }

        statusMessage.hidden = true
        backToAuctionButton.hidden = true
        placeHigherBidButton.hidden = true

        spinner.animate(animate)

        titleLabel.text = placingBid ? "Placing bid..." : "Registering..."

        // The view model will perform actions like registering a user if necessary,
        // placing a bid if requested, and polling for results.
        viewModel.performActions().subscribeError({ [weak self] (error) -> Void in
            self?.bidderError(error)
        }, completed: { [weak self] () -> Void in
            self?.finishUp()
        })
    }


    func finishUp() {
        self.spinner.hidden = true

        let reserveNotMet = viewModel.reserveNotMet
        let isHighestBidder = viewModel.isHighestBidder
        let bidIsResolved = viewModel.bidIsResolved
        let createdNewBidder = viewModel.createdNewBidder

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

        } else { // Not placing bid
            if createdNewBidder { // Creating new user
                handleRegistered()
            } else { // Updating existing user
                handleUpdate()
            }
        }

        let showPlaceHigherButton = placingBid && (!isHighestBidder || reserveNotMet)
        placeHigherBidButton.hidden = !showPlaceHigherButton

        let showAuctionButton = showPlaceHigherButton || isHighestBidder || (!placingBid && !createdNewBidder)
        backToAuctionButton.hidden = !showAuctionButton

        let title = reserveNotMet ? "NO, THANKS" : (createdNewBidder ? "CONTINUE" : "BACK TO AUCTION")
        backToAuctionButton.setTitle(title, forState: .Normal)
    }

    func handleRegistered() {
        titleLabel.text = "Registration Complete"
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")
        fulfillmentContainer()?.cancelButton.setTitle("DONE", forState: .Normal)
        RACSignal.interval(1, onScheduler: RACScheduler.mainThreadScheduler()).take(1).subscribeCompleted { [weak self] () -> Void in
            self?.performSegue(.PushtoRegisterConfirmed)
            return
        }
    }

    func handleUpdate() {
        titleLabel.text = "Updated your Information"
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")
        fulfillmentContainer()?.cancelButton.setTitle("DONE", forState: .Normal)
    }

    func handleUnknownBidder() {
        titleLabel.text = "Bid Confirmed"
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")
    }

    func handleReserveNotMet() {
        titleLabel.text = "Reserve Not Met"
        statusMessage.hidden = false
        statusMessage.text = "Your bid is still below this lot's reserve. Please place a higher bid."
        bidConfirmationImageView.image = UIImage(named: "BidNotHighestBidder")
    }

    func handleHighestBidder() {
        titleLabel.text = "High Bid!"
        statusMessage.hidden = false
        statusMessage.text = "You are the high bidder for this lot."
        bidConfirmationImageView.image = UIImage(named: "BidHighestBidder")

        recognizer.rac_gestureSignal().subscribeNext { [weak self] _ -> Void in
            self?.closeSelf()
        }

        bidConfirmationImageView.userInteractionEnabled = true
        bidConfirmationImageView.addGestureRecognizer(recognizer)

        fulfillmentContainer()?.cancelButton.setTitle("DONE", forState: .Normal)
    }

    func handleLowestBidder() {
        titleLabel.text = "Higher bid needed"
        titleLabel.textColor = UIColor.artsyRed()
        statusMessage.hidden = false
        statusMessage.text = "Another bidder has placed a higher maximum bid. Place a higher bid to secure the lot."
        bidConfirmationImageView.image = UIImage(named: "BidNotHighestBidder")
    }

    // MARK: - Error Handling

    func bidderError(error: NSError?) {
        if placingBid {
            // If you are bidding, we show a bidding error regardless of whether or not you're also registering.
            bidPlacementFailed(error)
        } else {
            // If you're not placing a bid, you're here because you're just registering.
            presentError("Registration Failed", message: "There was a problem registering for the auction. Please speak to an Artsy representative.")
        }
    }

    func bidPlacementFailed(error: NSError? = nil) {
        presentError("Bid Failed", message: "There was a problem placing your bid. Please speak to an Artsy representative.")

        if let error = error {
            statusMessage.presentOnLongPress("Error: \(error.localizedDescription). \n \(error.artsyServerError())", title: "Bidding error", closure: { [weak self] (alertController) -> Void in
                self?.presentViewController(alertController, animated: true, completion: nil)
            })
        }
    }

    func presentError(title: String, message: String) {
        spinner.hidden = true
        titleLabel.textColor = UIColor.artsyRed()
        titleLabel.text = title
        statusMessage.text = message
        statusMessage.hidden = false
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .PushtoRegisterConfirmed {
            let detailsVC = segue.destinationViewController as! YourBiddingDetailsViewController
            detailsVC.confirmationImage = bidConfirmationImageView.image
        }

        if segue == .PlaceaHigherBidAfterNotBeingHighestBidder {
            let placeBidVC = segue.destinationViewController as! PlaceBidViewController
            placeBidVC.hasAlreadyPlacedABid = true
        }
    }

    @IBAction func placeHigherBidTapped(sender: AnyObject) {
        self.fulfillmentNav().bidDetails.bidAmountCents = 0
        self.performSegue(.PlaceaHigherBidAfterNotBeingHighestBidder)
    }

    @IBAction func backToAuctionTapped(sender: AnyObject) {
        if viewModel.createdNewBidder {
            self.performSegue(.PushtoRegisterConfirmed)
        } else {
            closeSelf()
        }
    }
}
