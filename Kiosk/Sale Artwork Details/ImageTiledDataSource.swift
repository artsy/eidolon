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
}