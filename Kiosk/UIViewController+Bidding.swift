import UIKit

extension UIViewController {
    func bid(auctionID: String, saleArtwork: SaleArtwork, allowAnimations: Bool, provider: Networking) {
        
        let storyboard = UIStoryboard.fulfillment()
        let containerController = storyboard.instantiateInitialViewController() as! FulfillmentContainerViewController
        containerController.allowAnimations = allowAnimations

        if let internalNav:FulfillmentNavigationController = containerController.internalNavigationController() {
            internalNav.auctionID = auctionID
            internalNav.bidDetails.saleArtwork = saleArtwork
            internalNav.provider = provider
        }

        // Present the VC, then once it's ready trigger it's own showing animations
        appDelegate().appViewController.present(containerController, animated: false) {
            containerController.viewDidAppearAnimation(containerController.allowAnimations)
        }
    }
}
