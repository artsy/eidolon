import UIKit
import ARAnalytics
import ReactiveCocoa
import Swift_RAC_Macros

class AppViewController: UIViewController, UINavigationControllerDelegate {
    var allowAnimations = true
    var auctionID = AppSetup.sharedState.auctionID

    @IBOutlet var countdownManager: ListingsCountdownManager!
    @IBOutlet var offlineBlockingView: UIView!
    @IBOutlet weak var registerToBidButton: ActionButton!

    let _apiPinger = APIPingManager()
    
    lazy var reachabilitySignal: RACSignal = { [weak self] in
        reachabilityManager.reachSignal
    }()
    lazy var apiPingerSignal: RACSignal = { [weak self] in
        self?._apiPinger.letOnlineSignal ?? RACSignal.empty()
    }()

    var registerToBidCommand = { () -> RACCommand in
        appDelegate().registerToBidCommand()
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> AppViewController {
        return storyboard.viewControllerWithID(.AppViewController) as! AppViewController
    }

    dynamic var sale = Sale(id: "", name: "", isAuction: true, startDate: NSDate(), endDate: NSDate(), artworkCount: 0, state: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        registerToBidButton.rac_command = registerToBidCommand()

        countdownManager.setFonts()

        let stubbingAPIResponses = RACSignal.`return`(APIKeys.sharedKeys.stubResponses)
        let internetNotReachable = RACSignal.combineLatest([reachabilitySignal, apiPingerSignal]).and()
        let hideOfflineView = RACSignal.combineLatest([stubbingAPIResponses, internetNotReachable]).or()

        RAC(offlineBlockingView, "hidden") <~ hideOfflineView

        RAC(self, "sale") <~ auctionRequestSignal(auctionID)
        RAC(self, "countdownManager.sale") <~ RACObserve(self, "sale")

        for controller in childViewControllers {
            if let nav = controller as? UINavigationController {
                nav.delegate = self
            }
        }
    }

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
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

        return XAppRequest(auctionEndpoint).filterSuccessfulStatusCodes().mapJSON().mapToObject(Sale.self).`catch`({ (error) -> RACSignal! in

            logger.log("Sale Artworks: Error handling thing: \(error.artsyServerError())")
            return RACSignal.empty()
        })
    }
}
