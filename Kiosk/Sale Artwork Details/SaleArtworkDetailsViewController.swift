import UIKit

class SaleArtworkDetailsViewController: UIViewController {
    var allowAnimations = true
    var auctionID = AppSetup.sharedState.auctionID
    
    var saleArtwork: SaleArtwork!

    override func viewDidLoad() {
        super.viewDidLoad()

        println("I have a sale artwork: \(saleArtwork.artwork.title)")
    }

    @IBAction func registerToBidButtonWasPressed(sender: AnyObject) {
        registerToBid(auctionID, allowAnimations: allowAnimations)
    }
    
    @IBAction func backWasPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
