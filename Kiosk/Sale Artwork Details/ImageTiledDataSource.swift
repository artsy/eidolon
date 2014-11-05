import Foundation

class TiledImageDataSourceWithImage: ARWebTiledImageDataSource {
    let image: Image

    init(image: Image) {
        self.image = image
        super.init()

        tileFormat = "jpg";
        tileBaseURL = NSURL(string: image.baseURL)
        tileSize = image.tileSize
        maxTiledHeight = image.maxTiledHeight
        maxTiledWidth = image.maxTiledWidth
        maxTileLevel = image.maxLevel
        minTileLevel = 11;
    }

    //need to be able to return nil

//    override func tiledImageView(imageView: ARTiledImageView!, imageTileForLevel level: Int, x: Int, y: Int) -> UIImage? {
//        return image.localImageTileForLevel(level, x:x, y:y) ?? nil
//    }

//    override func tiledImageView(imageView: ARTiledImageView!, didDownloadTiledImage image: UIImage!, atURL url: NSURL!) {
//
//    }
}