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
    let registrationNetworkModel = RegistrationNetworkModel()

    dynamic var placingBid = false
    dynamic var createNewUser = false
    dynamic var details:BidDetails!
    
    class func instantiateFromStoryboard() -> RegisterViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.RegisterAnAccount) as RegisterViewController
    }

    func internalNavController() -> UINavigationController? {
        return self.childViewControllers.first as? UINavigationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        actionSpinner.hidden = true

        coordinator.storyboard = self.storyboard!
        let registerIndexSignal = RACObserve(coordinator, "currentIndex")
        let indexIsConfirmSignal = registerIndexSignal.map { return ($0 as Int == RegistrationIndex.ConfirmVC.toInt()) }
        
        RAC(confirmButton, "hidden") <~ indexIsConfirmSignal.notEach()
        RAC(flowView, "highlightedIndex") <~ registerIndexSignal

        RAC(registrationNetworkModel, "createNewUser") <~ RACObserve(self, "createNewUser")
        RAC(registrationNetworkModel, "details") <~ RACObserve(self, "details")
        registrationNetworkModel.fulfillmentNav = self.fulfillmentNav()

        details = self.fulfillmentNav().bidDetails
        flowView.details = details
        bidDetailsPreviewView.bidDetails = details

        flowView.jumpToIndexSignal.subscribeNext { [weak self] (index) -> Void in
            if let nav = self?.navigationController as? FulfillmentNavigationController {
                if index as? Int == self?.coordinator.currentIndex { return }

                let registrationIndex = RegistrationIndex.fromInt(index as Int)

                let nextVC = self?.coordinator.viewControllerForIndex(registrationIndex)
                self?.goToViewController(nextVC!)
            }
        }

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

    @IBOutlet weak var actionSpinner: Spinner!
    @IBAction func confirmTapped(sender: ActionButton) {
        if placingBid {
            passThroughToBiddingVCToCreateUser()

        } else {
            registerNewUser()
            sender.setTitle("", forState: .Normal)
            sender.enabled = false
            actionSpinner.hidden = false
        }
    }

    func registerNewUser() {
        confirmButton.enabled = false

        registrationNetworkModel.registerSignal().subscribeNext({ [weak self] (_) -> Void in

            self?.performSegue(.RegistrationFinishedShowBidDetails)
            return

            }, error: { [weak self] (error) -> Void in
                println("Error with registrationNetworkModel create or update")
        })
    }

    func passThroughToBiddingVCToCreateUser() {
        self.performSegue(.RegistrationFinishedPlaceBid)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue == .RegistrationFinishedPlaceBid {
            let nextViewController = segue.destinationViewController as PlacingBidViewController
            nextViewController.registerNetworkModel = registrationNetworkModel
        }
    }
}
