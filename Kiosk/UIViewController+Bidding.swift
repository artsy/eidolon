import UIKit

extension UIViewController {
    func bid(auctionID: String, saleArtwork: SaleArtwork, allowAnimations: Bool) {
        ARAnalytics.event("Bid Button Tapped")
        
        let storyboard = UIStoryboard.fulfillment()
        let containerController = storyboard.instantiateInitialViewController() as FulfillmentContainerViewController
        containerController.allowAnimations = allowAnimations

        if let internalNav:FulfillmentNavigationController = containerController.internalNavigationController() {
            internalNav.auctionID = auctionID
            internalNav.bidDetails.saleArtwork = saleArtwork
        }

        // Present the VC, then once it's ready trigger it's own showing animations
        // TODO: This is messy. Clean up somehow – responder chain?
        navigationController?.parentViewController?.presentViewController(containerController, animated: false) {
            containerController.viewDidAppearAnimation(containerController.allowAnimations)
        }
    }
}