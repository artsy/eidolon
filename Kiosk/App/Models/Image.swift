import Foundation
import LlamaKit

class Image: JSONAble {
    let id: String
    let imageFormatString: String
    let imageVersions: [String]
    let imageSize: CGSize

    init(id: String, imageFormatString: String, imageVersions: [String], imageSize: CGSize) {
        self.id = id
        self.imageFormatString = imageFormatString
        self.imageVersions = imageVersions
        self.imageSize = imageSize
    }

    override class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(json)

        let id = json["id"].stringValue
        let imageFormatString = json["image_url"].stringValue
        let imageVersions = json["image_versions"].object as [String]
        let imageSize = CGSize(width: json["original_width"].int!, height: json["original_height"].int!)

        return Image(id: id, imageFormatString: imageFormatString, imageVersions: imageVersions, imageSize: imageSize)
    }

    func thumbnailURL() -> NSURL? {
        let formats = ["large", "medium", "larger"]
        
        if let format = formats.filter({ contains(self.imageVersions, $0) }).first {
            let path = NSString(string: self.imageFormatString).stringByReplacingOccurrencesOfString(":version", withString: format)
            return NSURL(string: path)
        }
        return nil
    }

}
