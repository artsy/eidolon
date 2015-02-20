import UIKit
import ARAnalytics
import ReactiveCocoa
import Swift_RAC_Macros

public class AppViewController: UIViewController, UINavigationControllerDelegate {
    var allowAnimations = true
    var auctionID = AppSetup.sharedState.auctionID

    @IBOutlet var countdownManager: ListingsCountdownManager!
    @IBOutlet public var offlineBlockingView: UIView!
    @IBOutlet weak var registerToBidButton: ActionButton!

    let reachability = ReachabilityManager()
    public var reachabilitySignal: RACSignal?

    let apiPinger = APIPingManager()
    var apiPingerSignal: RACSignal?


    dynamic var sale = Sale(id: "", name: "", isAuction: true, startDate: NSDate(), endDate: NSDate(), artworkCount: 0, state: "")

    public override func viewDidLoad() {
        super.viewDidLoad()

        registerToBidButton.rac_command = appDelegate().registerToBidCommand()

        countdownManager.setFonts()

        let reachableSignal:RACSignal = reachabilitySignal ?? reachability.reachSignal
        let pingerSignal:RACSignal = apiPingerSignal ?? apiPinger.letOnlineSignal

        RAC(offlineBlockingView, "hidden") <~ RACSignal.combineLatest([reachableSignal, pingerSignal]).and()

        RAC(self, "sale") <~ auctionRequestSignal(auctionID)
        RAC(self, "countdownManager.sale") <~ RACObserve(self, "sale")

        for controller in childViewControllers {
            if let nav = controller as? UINavigationController {
                nav.delegate = self
            }
        }
    }

    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        let hide = (viewController as? SaleArtworkZoomViewController != nil)
        countdownManager.setLabelsHiddenIfSynced(hide)
        registerToBidButton.hidden = hide
    }
}

extension AppViewController {

    @IBAction func longPressForAdmin(sender: UIGestureRecognizer) {
        if sender.state != .Began {
            return
        }
        
        let passwordVC = PasswordAlertViewController.alertView { [weak self] () -> () in
            self?.performSegue(.ShowAdminOptions)
            return
        }
        self.presentViewController(passwordVC, animated: true) {}
    }

    func auctionRequestSignal(auctionID: String) -> RACSignal {
        let auctionEndpoint: ArtsyAPI = ArtsyAPI.AuctionInfo(auctionID: auctionID)

        return XAppRequest(auctionEndpoint).filterSuccessfulStatusCodes().mapJSON().mapToObject(Sale.self).catch({ (error) -> RACSignal! in

            logger.log("Sale Artworks: Error handling thing: \(error.artsyServerError())")
            return RACSignal.empty()
        })
    }
}
