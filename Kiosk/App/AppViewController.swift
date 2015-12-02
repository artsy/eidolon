import UIKit
import RxSwift
import Action

class AppViewController: UIViewController, UINavigationControllerDelegate {
    var allowAnimations = true
    var auctionID = AppSetup.sharedState.auctionID

    @IBOutlet var countdownManager: ListingsCountdownManager!
    @IBOutlet var offlineBlockingView: UIView!
    @IBOutlet weak var registerToBidButton: ActionButton!

    let _apiPinger = APIPingManager()
    
    lazy var reachabilitySignal: Observable<Bool> = {
        [connectedToInternetOrStubbingSignal(), self.apiPingerSignal].combineLatestAnd()
    }()

    lazy var apiPingerSignal: Observable<Bool> = {
        self._apiPinger.letOnlineSignal
    }()

    var registerToBidCommand = { () -> CocoaAction in
        appDelegate().registerToBidCommand()
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> AppViewController {
        return storyboard.viewControllerWithID(.AppViewController) as! AppViewController
    }

    var sale = Variable(Sale(id: "", name: "", isAuction: true, startDate: NSDate(), endDate: NSDate(), artworkCount: 0, state: ""))

    override func viewDidLoad() {
        super.viewDidLoad()

        registerToBidButton.rx_action = registerToBidCommand()

        countdownManager.setFonts()

        reachabilitySignal
            .bindTo(offlineBlockingView.rx_hidden)
            .addDisposableTo(rx_disposeBag)

        auctionRequestSignal(auctionID)
            .bindTo(sale)
            .addDisposableTo(rx_disposeBag)

        sale
            .asObservable()
            .mapToOptional()
            .bindTo(countdownManager.sale)
            .addDisposableTo(rx_disposeBag)

        for controller in childViewControllers {
            if let nav = controller as? UINavigationController {
                nav.delegate = self
            }
        }
    }

    deinit {
        countdownManager.invalidate()
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
        
        let passwordVC = PasswordAlertViewController.alertView { [weak self] in
            self?.performSegue(.ShowAdminOptions)
            return
        }
        self.presentViewController(passwordVC, animated: true) {}
    }

    func auctionRequestSignal(auctionID: String) -> Observable<Sale> {
        let auctionEndpoint: ArtsyAPI = ArtsyAPI.AuctionInfo(auctionID: auctionID)

        return XAppRequest(auctionEndpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObject(Sale)
            .logError()
            .retry()
            .throttle(1, MainScheduler.sharedInstance)
    }
}
