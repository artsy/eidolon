import Foundation
import SwiftyJSON

final class Artwork: NSObject, JSONAbleType {
    let id: String

    let dateString: String
    @objc dynamic let title: String
    var titleAndDate: NSAttributedString {
        return titleAndDateAttributedString(self.title, dateString: self.date)
    }
    @objc dynamic let price: String
    @objc dynamic let date: String

    @objc dynamic var soldStatus: NSNumber
    @objc dynamic var medium: String?
    @objc dynamic var dimensions = [String]()

    @objc dynamic var imageRights: String?
    @objc dynamic var additionalInfo: String?
    @objc dynamic var blurb: String?

    @objc dynamic var artists: [Artist]?
    @objc dynamic var culturalMarker: String?

    @objc dynamic var images: [Image]?

    lazy var defaultImage: Image? = {
        let defaultImages = self.images?.filter { $0.isDefault }

        return defaultImages?.first ?? self.images?.first
    }()

    init(id: String, dateString: String, title: String, price: String, date: String, sold: NSNumber) {
        self.id = id
        self.dateString = dateString
        self.title = title
        self.price = price
        self.date = date
        self.soldStatus = sold
    }

    static func fromJSON(_ json: [String: Any]) -> Artwork {
        let json = JSON(json)

        let id = json["id"].stringValue
        let title = json["title"].stringValue
        let dateString = json["date"].stringValue
        let price = json["price"].stringValue
        let date = json["date"].stringValue
        let sold = (json["sold"].bool ?? false) as NSNumber // Default to false if parsing fails.
        
        let artwork = Artwork(id: id, dateString: dateString, title: title, price: price, date: date, sold: sold)

        artwork.additionalInfo = json["additional_information"].string
        artwork.medium = json["medium"].string
        artwork.blurb = json["blurb"].string

        if let artistDictionary = json["artist"].object as? [String: AnyObject] {
            artwork.artists = [Artist.fromJSON(artistDictionary)]
        }

        if let imageDicts = json["images"].object as? Array<Dictionary<String, AnyObject>> {
            // There's a possibility that image_versions comes back as null from the API, which fromJSON() is allergic to.
            artwork.images = imageDicts.filter { dict -> Bool in
                let imageVersions = (dict["image_versions"] as? [String]) ?? []
                return imageVersions.count > 0
            }.map { return Image.fromJSON($0) }
        }

        if let dimensions = json["dimensions"].dictionary {
            artwork.dimensions = ["in", "cm"].reduce([String](), { (array, key) -> [String] in
                if let dimension = dimensions[key]?.string {
                    return array + [dimension]
                } else {
                    return array
                }
            })
        }

        return artwork
    }

    func updateWithValues(_ newArtwork: Artwork) {
        // soldStatus is the only value we expect to change at runtime.
        soldStatus = newArtwork.soldStatus
    }

    func sortableArtistID() -> String {
        return artists?.first?.sortableID ?? "_"
    }
}

private func titleAndDateAttributedString(_ title: String, dateString: String) -> NSAttributedString {
    let workTitle = title.isEmpty ? "Untitled" : title

    let workFont = UIFont.serifItalicFont(withSize: 16)!
    let attributedString = NSMutableAttributedString(string: workTitle, attributes: [NSAttributedStringKey.font : workFont])
    
    if dateString.isNotEmpty {
        let dateFont = UIFont.serifFont(withSize: 16)!
        let dateString = NSAttributedString(string: ", " + dateString, attributes: [NSAttributedStringKey.font : dateFont])
        attributedString.append(dateString)
    }
    
    return attributedString.copy() as! NSAttributedString
}
