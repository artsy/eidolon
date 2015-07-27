import UIKit
import ReactiveCocoa
import Swift_RAC_Macros

@objc protocol RegistrationSubController {
    // I know, leaky abstraction, but the amount
    // of useless syntax to change it isn't worth it.

    var finishedSignal: RACSubject { get }
}

class RegisterViewController: UIViewController {

    @IBOutlet var flowView: RegisterFlowView!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    @IBOutlet var confirmButton: UIButton!

    let coordinator = RegistrationCoordinator()

    dynamic var placingBid = true

    func internalNavController() -> UINavigationController? {
        return self.childViewControllers.first as? UINavigationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        coordinator.storyboard = self.storyboard!
        let registerIndexSignal = RACObserve(coordinator, "currentIndex")
        let indexIsConfirmSignal = registerIndexSignal.map { return ($0 as! Int == RegistrationIndex.ConfirmVC.toInt()) }
        
        RAC(confirmButton, "hidden") <~ indexIsConfirmSignal.not()
        RAC(flowView, "highlightedIndex") <~ registerIndexSignal

        let details = self.fulfillmentNav().bidDetails
        flowView.details = details
        bidDetailsPreviewView.bidDetails = details

        flowView.jumpToIndexSignal.subscribeNext { [weak self] (index) -> Void in
            if let nav = self?.fulfillmentNav() {
                let registrationIndex = RegistrationIndex.fromInt(index as! Int)

                let nextVC = self?.coordinator.viewControllerForIndex(registrationIndex)
                self?.goToViewController(nextVC!)
            }
        }

        goToNextVC()
    }

    func goToNextVC() {
        let nextVC = coordinator.nextViewControllerForBidDetails(fulfillmentNav().bidDetails)
        goToViewController(nextVC)

    }

    func goToViewController(controller: UIViewController) {
        self.internalNavController()!.viewControllers = [controller]

        if let subscribableVC = controller as? RegistrationSubController {
            subscribableVC.finishedSignal.subscribeCompleted({ [weak self] () -> Void in
                self?.goToNextVC()
                self?.flowView.update()
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue == .ShowLoadingView {
            let nextViewController = segue.destinationViewController as! LoadingViewController
            nextViewController.placingBid = placingBid
        }
    }
}
