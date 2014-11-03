import UIKit

extension UIViewController {
    func registerToBid(auctionID: String, allowAnimations: Bool = false) {
        ARAnalytics.event("Register To Bid Tapped")
        
        let storyboard = UIStoryboard.fulfillment()
        let containerController = storyboard.instantiateInitialViewController() as FulfillmentContainerViewController
        containerController.allowAnimations = allowAnimations
        
        if let internalNav:FulfillmentNavigationController = containerController.internalNavigationController() {
            let registerVC = storyboard.viewControllerWithID(.RegisterAnAccount) as RegisterViewController
            registerVC.placingBid = false
            internalNav.auctionID = auctionID
            internalNav.viewControllers = [registerVC]
        }
        
        self.presentViewController(containerController, animated: false) {
            containerController.viewDidAppearAnimation(containerController.allowAnimations)
        }

    }
}