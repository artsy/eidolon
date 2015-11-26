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
        let registerIndexSignal = coordinator.currentIndex
        let indexIsConfirmSignal = registerIndexSignal.map { return ($0 == RegistrationIndex.ConfirmVC.toInt()) }

        indexIsConfirmSignal
            .not()
            .bindTo(confirmButton.rx_hidden)
            .addDisposableTo(rx_disposeBag)

        registerIndexSignal
            .bindTo(flowView.highlightedIndex)
            .addDisposableTo(rx_disposeBag)

        let details = self.fulfillmentNav().bidDetails
        flowView.details = details
        bidDetailsPreviewView.bidDetails = details

        flowView.jumpToIndexSignal.subscribeNext { [weak self] (index) -> Void in
            if let _ = self?.fulfillmentNav() {
                let registrationIndex = RegistrationIndex.fromInt(index as! Int)

                let nextVC = self?.coordinator.viewControllerForIndex(registrationIndex)
                self?.goToViewController(nextVC!)
            }
        }

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
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue == .ShowLoadingView {
            let nextViewController = segue.destinationViewController as! LoadingViewController
            nextViewController.placingBid = placingBid
        }
    }
}
