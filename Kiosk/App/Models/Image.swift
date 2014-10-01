import Foundation
import LlamaKit

class Image: JSONAble {
    let id: String
    let imageFormatString: String
    let imageVersions:[String]

    init(id: String, imageFormatString: String, imageVersions: [String]) {
        self.id = id
        self.imageFormatString = imageFormatString
        self.imageVersions = imageVersions
    }

    override class func fromJSON(json:[String: AnyObject]) -> JSONAble {
        let json = JSON(object: json)

        let id = json["id"].stringValue
        let imageFormatString = json["image_url"].stringValue
        let imageVersions = json["image_versions"].object as [String]

        return Image(id: id, imageFormatString: imageFormatString, imageVersions: imageVersions)
    }

    func thumbnailURL() -> NSURL? {
        let formats = ["large", "medium", "larger"]
        
        if let format:String? = formats.filter({ contains(self.imageVersions, $0) }).first {
            if format != nil {
                let path = NSString(string: format!).stringByReplacingOccurrencesOfString(":version", withString: format!)
                return NSURL(string: path)
            }

        }
        return nil
    }

}
