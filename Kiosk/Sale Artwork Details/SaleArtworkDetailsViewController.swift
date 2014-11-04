import UIKit

class SaleArtworkDetailsViewController: UIViewController {
    var allowAnimations = true
    var auctionID = AppSetup.sharedState.auctionID
    var saleArtwork: SaleArtwork!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupImageView()
    }
}

extension SaleArtworkDetailsViewController {
    @IBAction func backWasPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    private func setupImageView() {
        if let image = saleArtwork.artwork.images?.first? {
            if let url = image.fullsizeURL() {
                imageView.sd_setImageWithURL(url, completed: { [weak self] image, error, type, url -> () in
                    self?.imageView.backgroundColor = UIColor.clearColor()
                    return
                })
            }

            imageViewHeightConstraint.constant = min(400, CGFloat(538) / image.aspectRatio)
        }
    }
}
