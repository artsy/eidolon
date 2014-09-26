import Foundation

final class Image: NSObject, JSONAble {
    let id:String
    let imageURL:String
    let imageVersions:[String]

    init(id: String, imageURL: String, imageVersions: [String]) {
        self.id = id
        self.imageURL = imageURL
        self.imageVersions = imageVersions
    }

    class func fromJSON(json:[String: AnyObject]) -> Image {
        let json = JSON(object: json)

        let id = json["id"].stringValue
        let imageURL = json["image_url"].stringValue
        let imageVersions = json["image_versions"].object as [String]

        return Image(id: id, imageURL: imageURL, imageVersions: imageVersions)
    }

}
