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

    var provider: Networking!

    let coordinator = RegistrationCoordinator()

    @objc dynamic var placingBid = true

    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    func internalNavController() -> UINavigationController? {
        return self.childViewControllers.first as? UINavigationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        coordinator.storyboard = self.storyboard!
        let indexIsConfirmed = coordinator.currentIndex.map { return ($0 == RegistrationIndex.confirmVC.toInt()) }

        indexIsConfirmed
            .not()
            .bind(to: confirmButton.rx_hidden)
            .disposed(by: rx.disposeBag)

        coordinator.currentIndex
            .bind(to: flowView.highlightedIndex)
            .disposed(by: rx.disposeBag)

        let details = self.fulfillmentNav().bidDetails
        flowView.details = details
        bidDetailsPreviewView.bidDetails = details

        goToNextVC()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _viewWillDisappear.onNext(Void())
    }

    func goToNextVC() {
        let nextVC = coordinator.nextViewControllerForBidDetails(fulfillmentNav().bidDetails)
        goToViewController(nextVC)
    }

    func goToViewController(_ controller: UIViewController) {
        self.internalNavController()!.viewControllers = [controller]

        if let subscribableVC = controller as? RegistrationSubController {
            subscribableVC
                .finished
                .subscribe(onCompleted: { [weak self] in
                    self?.goToNextVC()
                    self?.flowView.update()
                })
                .disposed(by: rx.disposeBag)
        }

        if let viewController = controller as? RegistrationPasswordViewController {
            viewController.provider = provider
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue == .ShowLoadingView {
            let nextViewController = segue.destination as! LoadingViewController
            nextViewController.placingBid = placingBid
            nextViewController.provider = provider
        }
    }
}
