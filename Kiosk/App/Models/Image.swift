import Foundation
import SwiftyJSON

final class Image: NSObject, JSONAbleType {
    let id: String
    let imageFormatString: String
    let imageVersions: [String]
    let imageSize: CGSize
    let aspectRatio: CGFloat?

    let baseURL: String
    let tileSize: Int
    let maxTiledHeight: Int
    let maxTiledWidth: Int
    let maxLevel: Int
    let isDefault: Bool

    init(id: String, imageFormatString: String, imageVersions: [String], imageSize: CGSize, aspectRatio: CGFloat?, baseURL: String, tileSize: Int, maxTiledHeight: Int, maxTiledWidth: Int, maxLevel: Int, isDefault: Bool) {
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
        self.isDefault = isDefault
    }

    static func fromJSON(json:[String: AnyObject]) -> Image {
        let json = JSON(json)

        let id = json["id"].stringValue
        let imageFormatString = json["image_url"].stringValue
        let imageVersions = (json["image_versions"].object as? [String]) ?? []
        let imageSize = CGSize(width: json["original_width"].int ?? 1, height: json["original_height"].int ?? 1)
        let aspectRatio = { () -> CGFloat? in
            if let aspectRatio = json["aspect_ratio"].float {
                return CGFloat(aspectRatio)
            }
            return nil
        }()

        let baseURL = json["tile_base_url"].stringValue
        let tileSize = json["tile_size"].intValue
        let maxTiledHeight = json["max_tiled_height"].int ?? 1
        let maxTiledWidth = json["max_tiled_width"].int ?? 1
        let isDefault = json["is_default"].bool ?? false

        let dimension = max( maxTiledWidth, maxTiledHeight)
        let logD = logf( Float(dimension) )
        let log2 = Float(logf(2))
        
        let maxLevel = Int( ceilf( logD / log2) )

        return Image(id: id, imageFormatString: imageFormatString, imageVersions: imageVersions, imageSize: imageSize, aspectRatio: aspectRatio, baseURL: baseURL, tileSize: tileSize, maxTiledHeight: maxTiledHeight, maxTiledWidth: maxTiledWidth, maxLevel: maxLevel, isDefault: isDefault)
    }

    func thumbnailURL() -> NSURL? {
        let preferredVersions = { () -> Array<String> in
            // This is a hack for https://www.artsy.net/artwork/d-star-face-work-on-paper-number-5
            // It's a very tall image and the "medium" version looks terribad.
            // In the long-term, we have an issue to fix this for good: https://github.com/artsy/eidolon/issues/396
            if self.id == "56ba2884139b211c61000204" {
                return ["large", "larger"]
            } else {
                return ["medium", "large", "larger"]
            }
        }()

        return urlFromPreferenceList(preferredVersions)
    }

    func fullsizeURL() -> NSURL? {
        return urlFromPreferenceList(["larger", "large", "medium"])
    }

    private func urlFromPreferenceList(preferenceList: Array<String>) -> NSURL? {
        if let format = preferenceList.filter({ self.imageVersions.contains($0) }).first {
            let path = NSString(string: self.imageFormatString).stringByReplacingOccurrencesOfString(":version", withString: format)
            return NSURL(string: path)
        }
        return nil
    }
}
