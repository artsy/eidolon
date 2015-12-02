import Foundation
import SwiftyJSON

final class Artwork: NSObject, JSONAbleType {

    enum SoldStatus {
        case NotSold
        case Sold

        static func fromString(string: String) -> SoldStatus {
            switch string.lowercaseString {
            case "sold":
                return .Sold
            default:
                return .NotSold
            }
        }
    }

    let id: String

    let dateString: String
    dynamic let title: String
    dynamic let titleAndDate: NSAttributedString
    dynamic let price: String
    dynamic let date: String

    dynamic var soldStatus: String
    dynamic var medium: String?
    dynamic var dimensions = [String]()

    dynamic var imageRights: String?
    dynamic var additionalInfo: String?
    dynamic var blurb: String?

    dynamic var artists: [Artist]?
    dynamic var culturalMarker: String?

    dynamic var images: [Image]?

    lazy var defaultImage: Image? = {
        let defaultImages = self.images?.filter { (image) -> Bool in
            image.isDefault
        }

        return defaultImages?.first ?? self.images?.first
    }()

    init(id: String, dateString: String, title: String, titleAndDate: NSAttributedString, price: String, date: String, sold: String) {
        self.id = id
        self.dateString = dateString
        self.title = title
        self.titleAndDate = titleAndDate
        self.price = price
        self.date = date
        self.soldStatus = sold
    }

    static func fromJSON(json: [String: AnyObject]) -> Artwork {
        let json = JSON(json)

        let id = json["id"].stringValue
        let title = json["title"].stringValue
        let dateString = json["date"].stringValue
        let price = json["price"].stringValue
        let date = json["date"].stringValue
        let sold = json["sold"].stringValue
        let titleAndDate = titleAndDateAttributedString(title, dateString: dateString)
        
        let artwork = Artwork(id: id, dateString: dateString, title: title, titleAndDate:titleAndDate, price: price, date: date, sold: sold)

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
            artwork.dimensions = ["in", "cm"].reduce([String](), combine: { (array, key) -> [String] in
                if let dimension = dimensions[key]?.string {
                    return array + [dimension]
                } else {
                    return array
                }
            })
        }

        return artwork
    }

    func updateWithValues(newArtwork: Artwork) {
        // soldStatus is the only value we expect to change at runtime.
        soldStatus = newArtwork.soldStatus
    }

    func sortableArtistID() -> String {
        return artists?.first?.sortableID ?? "_"
    }
}

private func titleAndDateAttributedString(title: String, dateString: String) -> NSAttributedString {
    let workTitle = title.isEmpty ? "Untitled" : title
    let workFont = UIFont.serifItalicFontWithSize(16)
    let attributedString = NSMutableAttributedString(string: workTitle, attributes: [NSFontAttributeName : workFont ])
    
    if dateString.isNotEmpty {
        let dateFont = UIFont.serifFontWithSize(16)
        let dateString = NSMutableAttributedString(string: ", " + dateString, attributes: [ NSFontAttributeName : dateFont ])
        attributedString.appendAttributedString(dateString)
    }
    
    return attributedString.copy() as! NSAttributedString
}
