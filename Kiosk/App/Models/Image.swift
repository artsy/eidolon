import Foundation
import LlamaKit

class Image: JSONAble {
    let id: String
    let imageFormatString: String
    let imageVersions: [String]
    let imageSize: CGSize
    let aspectRatio: CGFloat

    let baseURL:String
    let tileSize: Int
    let maxTiledHeight: Int
    let maxTiledWidth: Int
    let maxLevel: Int

    init(id: String, imageFormatString: String, imageVersions: [String], imageSize: CGSize, aspectRatio: CGFloat, baseURL: String, tileSize: Int, maxTiledHeight: Int, maxTiledWidth: Int, maxLevel: Int) {
        self.id = id
        self.imageFormatString = imageFormatString
        self.imageVersions = imageVersions
        self.imageSize = imageSize
        self.aspectRatio = aspectRatio
        self.baseURL = baseURL
        self.tileSize = tileSize
        self.maxTiledHeight = maxTiledHeight
        self.maxTiledWidth = maxTiledWidth
        self.maxLevel = maxLevel
    }

    override class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(json)

        let id = json["id"].stringValue
        let imageFormatString = json["image_url"].stringValue
        let imageVersions = json["image_versions"].object as [String]
        let imageSize = CGSize(width: json["original_width"].int ?? 1, height: json["original_height"].int ?? 1)
        let aspectRatio = CGFloat( json["aspect_ratio"].floatValue )

        let baseURL = json["tile_base_url"].stringValue
        let tileSize = json["tile_size"].intValue
        let maxTiledHeight = json["max_tiled_height"].intValue
        let maxTiledWidth = json["max_tiled_width"].intValue

        let dimension = max( maxTiledWidth, maxTiledHeight)
        let logD = logf( Float(dimension) )
        let log2 = Float(logf(2))
        
        let maxLevel = Int( ceilf( logD / log2) )

        return Image(id: id, imageFormatString: imageFormatString, imageVersions: imageVersions, imageSize: imageSize, aspectRatio:aspectRatio, baseURL: baseURL, tileSize: tileSize, maxTiledHeight: maxTiledHeight, maxTiledWidth: maxTiledWidth, maxLevel: maxLevel)
    }

    func thumbnailURL() -> NSURL? {
        return urlFromPreferenceList(["large", "medium", "larger"])
    }

    func fullsizeURL() -> NSURL? {
        return urlFromPreferenceList(["larger", "medium", "large"])
    }

    func localImageTileForLevel(level:Int, x:Int, y:Int) -> UIImage? {
        let path = localPathForImageTileAtLevel(level, x:x, y:y)
        return UIImage(contentsOfFile:path)
    }

    func localPathForImageTileAtLevel(level:Int, x:Int, y:Int) -> NSString {
        let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
        return ""
    }

    private func urlFromPreferenceList(preferenceList: Array<String>) -> NSURL? {
        if let format = preferenceList.filter({ contains(self.imageVersions, $0) }).first {
            let path = NSString(string: self.imageFormatString).stringByReplacingOccurrencesOfString(":version", withString: format)
            return NSURL(string: path)
        }
        return nil
    }
}
