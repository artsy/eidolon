import UIKit
import Swift_RAC_Macros
import Artsy_UILabels
import Artsy_UIButtons
import Dollar

class YourBiddingDetailsViewController: UIViewController {

    @IBOutlet dynamic var bidderNumberLabel: UILabel!
    @IBOutlet dynamic var pinNumberLabel: UILabel!

    @IBOutlet weak var confirmationImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: ARSerifLabel!
    @IBOutlet weak var bodyLabel: ARSerifLabel!
    @IBOutlet weak var notificationLabel: ARSerifLabel!

    var confirmationImage: UIImage?

    lazy var bidDetails: BidDetails! = { (self.navigationController as! FulfillmentNavigationController).bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        $.each([notificationLabel, bidderNumberLabel, pinNumberLabel]) { $0.makeTransparent() }
        notificationLabel.setLineHeight(5)
        bodyLabel.setLineHeight(10)

        if let image = confirmationImage {
            confirmationImageView.image = image
        }

        bodyLabel?.makeSubstringsBold(["Bidder Number", "PIN"])

        RAC(bidderNumberLabel, "text") <~ RACObserve(bidDetails, "paddleNumber")
        RAC(pinNumberLabel, "text") <~ RACObserve(bidDetails, "bidderPIN")
    }

    @IBAction func confirmButtonTapped(sender: AnyObject) {
        fulfillmentContainer()?.closeFulfillmentModal()
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> YourBiddingDetailsViewController {
        return storyboard.viewControllerWithID(.YourBidderDetails) as! YourBiddingDetailsViewController
    }
}
