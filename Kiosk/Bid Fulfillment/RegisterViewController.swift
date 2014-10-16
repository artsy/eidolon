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
        
        let registerIndexSignal = RACObserve(coordinator, "currentIndex")
        let indexIsConfirmSignal = registerIndexSignal.map { return ($0 as Int == RegistrationIndex.ConfirmVC.toInt()) }
        
        RAC(confirmButton, "hidden") <~ indexIsConfirmSignal.notEach()
        RAC(flowView, "highlightedIndex") <~ registerIndexSignal

        RAC(registrationNetworkModel, "createNewUser") <~ RACObserve(self, "createNewUser")
        RAC(registrationNetworkModel, "details") <~ RACObserve(self, "details")
        registrationNetworkModel.fulfilmentNav = self.fulfilmentNav()

        details = self.fulfillmentNav().bidDetails
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
        confirmButton.enabled = false
        
        registrationNetworkModel.completedSignal.subscribeNext({ [weak self] (_) -> Void in

            self?.performSegue(.RegistrationFinishedShowBidDetails)
            return
            
        }, error: { [weak self] (error) -> Void in
            println("Error with registrationNetworkModel create or update")
        })
        
        registrationNetworkModel.start()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue == .RegistrationFinishedShowBidDetails {
            let nextViewController = segue.destinationViewController as YourBiddingDetailsViewController
            nextViewController.finishAfterViewController = createNewUser
        }
    }
}
