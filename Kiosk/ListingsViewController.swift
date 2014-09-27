import UIKit

class ListingsViewController: UIViewController {
    var allowAnimations:Bool = true;
    
    @IBAction func showModal(sender: AnyObject) {

        let endpoint: ArtsyAPI = ArtsyAPI.AuctionListings(id: "ici-live-auction")

        XAppRequest(endpoint, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(SaleArtwork.self).subscribeNext({ [weak self] (objects) -> Void in

            let saleArtworks = objects as [SaleArtwork]
            let storyboard = UIStoryboard.fulfillment()
            let containerController = storyboard.instantiateInitialViewController() as FulfillmentContainerViewController

            for saleArtwork in saleArtworks {
                println("SA: \(saleArtwork.id) - \(saleArtwork.artwork.title)");
            }

            if let placeBidVC = containerController.placeBidViewController() {
                placeBidVC.saleArtwork = saleArtworks.first
            }

            self?.presentViewController(containerController, animated: self!.allowAnimations, completion: nil)

        }, error: { (error) -> Void in
            println("Error: \(error.localizedDescription)")
        })
        

    }

}

