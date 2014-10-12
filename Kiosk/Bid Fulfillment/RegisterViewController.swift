import UIKit

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
    var closeModalAfterCompletion = false

    class func instantiateFromStoryboard() -> RegisterViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.RegisterAnAccount) as RegisterViewController
    }

    func internalNavController() -> UINavigationController? {
        return self.childViewControllers.first as? UINavigationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let registerIndexSignal = RACObserve(coordinator, "currentIndex")
        let indexIsConfirmSignal = registerIndexSignal.map { return ($0 as Int == RegistrationIndex.ConfirmVC.toInt()) }
        
        RAC(confirmButton, "hidden") <~ indexIsConfirmSignal.notEach()
        RAC(flowView, "highlightedIndex") <~ registerIndexSignal

        let details = self.fulfilmentNav().bidDetails
        flowView.details = details
        bidDetailsPreviewView.bidDetails = details
        
        goToNextVC()
    }

    func goToNextVC() {
        if let nav = self.navigationController as? FulfillmentNavigationController {
            let nextVC = coordinator.nextViewControllerForBidDetails(nav.bidDetails)
            goToViewController(nextVC)
        }
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

    @IBAction func confirmTapped(sender: AnyObject) {
        if closeModalAfterCompletion {
            self.fulfilmentNav().parentViewController?.dismissViewControllerAnimated(true, completion: nil)

        } else {
            self.performSegue(.ConfirmRegistrationandBid)
        }
    }
}
