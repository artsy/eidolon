import Foundation
import ARTiledImageView

class SaleArtworkZoomViewController: UIViewController {
    var dataSource: TiledImageDataSourceWithImage!
    var saleArtwork: SaleArtwork!
    var tiledImageView: ARTiledImageScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let image = saleArtwork.artwork.defaultImage!
        dataSource = TiledImageDataSourceWithImage(image:image)

        let tiledView = ARTiledImageScrollView(frame:view.bounds)
        tiledView.decelerationRate = UIScrollViewDecelerationRateFast
        tiledView.showsHorizontalScrollIndicator = false
        tiledView.showsVerticalScrollIndicator = false
        tiledView.contentMode = .ScaleAspectFit
        tiledView.dataSource = dataSource
        tiledView.backgroundImageURL = image.fullsizeURL()

        view.insertSubview(tiledView, atIndex:0)
        tiledImageView = tiledView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        tiledImageView.zoomToFit(false)
    }

    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
