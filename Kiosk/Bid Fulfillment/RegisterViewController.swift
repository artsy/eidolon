import UIKit
import RxSwift

protocol RegistrationSubController {
    // I know, leaky abstraction, but the amount
    // of useless syntax to change it isn't worth it.

    var finished: PublishSubject<Void> { get }
}

class RegisterViewController: UIViewController {

    @IBOutlet var flowView: RegisterFlowView!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    @IBOutlet var confirmButton: UIButton!

    var provider: NetworkingType!

    let coordinator = RegistrationCoordinator()

    dynamic var placingBid = true

    private let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    func internalNavController() -> UINavigationController? {
        return self.childViewControllers.first as? UINavigationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        coordinator.storyboard = self.storyboard!
        let registerIndex = coordinator.currentIndex
        let indexIsConfirmed = registerIndex.map { return ($0 == RegistrationIndex.ConfirmVC.toInt()) }

        indexIsConfirmed
            .not()
            .bindTo(confirmButton.rx_hidden)
            .addDisposableTo(rx_disposeBag)

        registerIndex
            .bindTo(flowView.highlightedIndex)
            .addDisposableTo(rx_disposeBag)

        let details = self.fulfillmentNav().bidDetails
        flowView.details = details
        bidDetailsPreviewView.bidDetails = details

        flowView
            .highlightedIndex
            .distinctUntilChanged()
            .subscribeNext { [weak self] (index) in
                if let _ = self?.fulfillmentNav() {
                    let registrationIndex = RegistrationIndex.fromInt(index)

                    let nextVC = self?.coordinator.viewControllerForIndex(registrationIndex)
                    self?.goToViewController(nextVC!)
                }
            }
            .addDisposableTo(rx_disposeBag)

        goToNextVC()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        _viewWillDisappear.onNext()
    }

    func goToNextVC() {
        let nextVC = coordinator.nextViewControllerForBidDetails(fulfillmentNav().bidDetails)
        goToViewController(nextVC)
    }

    func goToViewController(controller: UIViewController) {
        self.internalNavController()!.viewControllers = [controller]

        if let subscribableVC = controller as? RegistrationSubController {
            subscribableVC
                .finished
                .subscribeCompleted { [weak self] in
                    self?.goToNextVC()
                    self?.flowView.update()
                }
                .addDisposableTo(rx_disposeBag)
        }

        if let viewController = controller as? RegistrationPasswordViewController {
            viewController.provider = provider
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue == .ShowLoadingView {
            let nextViewController = segue.destinationViewController as! LoadingViewController
            nextViewController.placingBid = placingBid
            nextViewController.provider = provider
        }
    }
}
