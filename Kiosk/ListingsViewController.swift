import UIKit

class ListingsViewController: UIViewController {
    var allowAnimations:Bool = true;

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showModal(self)
    }

    @IBAction func showModal(sender: AnyObject) {

        let endpoint: ArtsyAPI = ArtsyAPI.AuctionListings(id: "ici-live-auction")

        XAppRequest(endpoint, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(SaleArtwork.self).subscribeNext({ [weak self] (objects) -> Void in

            let saleArtworks = objects as [SaleArtwork]
            let storyboard = UIStoryboard.fulfillment()
            let containerController = storyboard.instantiateInitialViewController() as FulfillmentContainerViewController

            if let placeBidVC = containerController.placeBidViewController() {
                let randomIndex = Int(arc4random_uniform(UInt32(saleArtworks.count)))
                placeBidVC.saleArtwork = saleArtworks[randomIndex]
            }

            self?.presentViewController(containerController, animated: self!.allowAnimations, completion: nil)

        }, error: { (error) -> Void in
            println("Error: \(error.localizedDescription)")
        })
        

    }

}

