import UIKit
import RxSwift
import Action

class AppViewController: UIViewController, UINavigationControllerDelegate {
    var allowAnimations = true
    var auctionID = AppSetup.sharedState.auctionID

    @IBOutlet var countdownManager: ListingsCountdownManager!
    @IBOutlet var offlineBlockingView: UIView!
    @IBOutlet weak var registerToBidButton: ActionButton!

    var provider: NetworkingType!

    lazy var _apiPinger: APIPingManager = {
        return APIPingManager(provider: self.provider)
    }()
    
    lazy var reachability: Observable<Bool> = {
        [connectedToInternetOrStubbing(), self.apiPinger].combineLatestAnd()
    }()

    lazy var apiPinger: Observable<Bool> = {
        self._apiPinger.letOnline
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
        countdownManager.provider = provider

        reachability
            .bindTo(offlineBlockingView.rx_hidden)
            .addDisposableTo(rx_disposeBag)

        auctionRequest(provider, auctionID: auctionID)
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // This is the embed segue
        guard let navigtionController = segue.destinationViewController as? UINavigationController else { return }
        guard let listingsViewController = navigtionController.topViewController as? ListingsViewController else { return }

        listingsViewController.provider = provider
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

    func auctionRequest(provider: NetworkingType, auctionID: String) -> Observable<Sale> {
        let auctionEndpoint: ArtsyAPI = ArtsyAPI.AuctionInfo(auctionID: auctionID)

        return provider.request(auctionEndpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObject(Sale)
            .logError()
            .retry()
            .throttle(1, MainScheduler.sharedInstance)
    }
}
