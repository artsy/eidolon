import Foundation
import SwiftyJSON

public class Artwork: JSONAble {
    public let id: String

    public let dateString: String
    public dynamic let title: String
    public dynamic let titleAndDate: NSAttributedString
    public dynamic let price: String
    public dynamic let date: String

    public dynamic var medium: String?
    public dynamic var dimensions = [String]()

    public dynamic var imageRights: String?
    public dynamic var additionalInfo: String?
    public dynamic var blurb: String?

    public dynamic var artists: [Artist]?
    public dynamic var culturalMarker: String?

    public dynamic var images: [Image]?

    public lazy var defaultImage: Image? = {
        let defaultImages = self.images?.filter({ (image) -> Bool in
            image.isDefault
        })

        return defaultImages?.first ?? self.images?.first
    }()

    init(id: String, dateString: String, title: String, titleAndDate: NSAttributedString, price: String, date: String) {
        self.id = id
        self.dateString = dateString
        self.title = title
        self.titleAndDate = titleAndDate
        self.price = price
        self.date = date
    }

    override public class func fromJSON(json: [String: AnyObject]) -> JSONAble {
        let json = JSON(json)

        let id = json["id"].stringValue
        let title = json["title"].stringValue
        let dateString = json["date"].stringValue
        let price = json["price"].stringValue
        let date = json["date"].stringValue
        let titleAndDate = titleAndDateAttributedString(title, dateString)
        
        let artwork = Artwork(id: id, dateString: dateString, title: title, titleAndDate:titleAndDate, price: price, date: date)

        artwork.additionalInfo = json["additional_information"].string
        artwork.medium = json["medium"].string
        artwork.blurb = json["blurb"].string

        if let artistDictionary = json["artist"].object as? [String: AnyObject] {
            artwork.artists = [Artist.fromJSON(artistDictionary) as Artist]
        }

        if let imageDicts = json["images"].object as? Array<Dictionary<String, AnyObject>> {
            artwork.images = imageDicts.map({ return Image.fromJSON($0) as Image })
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

    func sortableArtistID() -> String {
        return artists?.first?.sortableID ?? "_"
    }
}

private func titleAndDateAttributedString(title: String, dateString: String) -> NSAttributedString {
    let workTitle = countElements(title) > 0 ? title : "Untitled"
    let workFont = UIFont.serifItalicFontWithSize(16)
    var attributedString = NSMutableAttributedString(string: workTitle, attributes: [NSFontAttributeName : workFont ])
    
    if countElements(dateString) > 0 {
        let dateFont = UIFont.serifFontWithSize(16)
        let dateString = NSMutableAttributedString(string: ", " + dateString, attributes: [ NSFontAttributeName : dateFont ])
        attributedString.appendAttributedString(dateString)
    }
    
    return attributedString.copy() as NSAttributedString
}
