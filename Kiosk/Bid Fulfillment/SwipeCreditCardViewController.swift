import UIKit

public class SwipeCreditCardViewController: UIViewController {

    @IBOutlet var cardStatusLabel: ARSerifLabel!
    @IBOutlet var registerFlowView: RegisterFlowView!

    public class func instantiateFromStoryboard() -> SwipeCreditCardViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.SwipeCreditCard) as SwipeCreditCardViewController
    }

    @IBAction public func dev_CardRegisteredTapped(sender: AnyObject) {
        self.performSegue(.CardRegistered)
    }

    lazy var keys = EidolonKeys()
    lazy var cardHandler:CardHandler = CardHandler(apiKey: self.keys.cardflightTestAPIClientKey(), accountToken: self.keys.cardflightMerchantAccountToken())
    

    public override func viewDidLoad() {
        super.viewDidLoad()

        cardHandler.cardSwipedSignal.subscribeNext({ [unowned self] (message) -> Void in
            self.cardStatusLabel.text = "Card Status: \(message)"

        }, error: { [unowned self] (error) -> Void in
            self.cardStatusLabel.text = "Card Status: Errored"

        }, completed: { [unowned self] () -> Void in
            self.cardStatusLabel.text = "Card Status: completed"
        })
        
        cardHandler.startSearching()

        if let nav = self.navigationController as? FulfillmentNavigationController {
            registerFlowView.details = nav.bidDetails
        }
    }
}
