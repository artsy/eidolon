import Foundation

class Artwork: JSONAble {
    let id: String

    let dateString: String
    dynamic let title: String
    dynamic let titleAndDate: NSAttributedString
    dynamic let blurb: String
    dynamic let price: String
    dynamic let date: String

    dynamic var medium: String?
    dynamic var dimensions = [String]()

    dynamic var imageRights: String?
    dynamic var additionalInfo: String?

    dynamic var artists: [Artist]?
    dynamic var culturalMarker: String?

    dynamic var images: [Image]?

    init(id: String, dateString: String, title: String, titleAndDate: NSAttributedString, blurb: String, price: String, date: String) {
        self.id = id
        self.dateString = dateString
        self.title = title
        self.titleAndDate = titleAndDate
        self.blurb = blurb
        self.price = price
        self.date = date
    }

    override class func fromJSON(json: [String: AnyObject]) -> JSONAble {
        let json = JSON(json)

        let id = json["id"].stringValue
        let title = json["title"].stringValue
        let dateString = json["date"].stringValue
        let blurb = json["blurb"].stringValue
        let price = json["price"].stringValue
        let date = json["date"].stringValue
        let titleAndDate = titleAndDateAttributedString(title, dateString)
        
        let artwork = Artwork(id: id, dateString: dateString, title: title, titleAndDate:titleAndDate, blurb: blurb, price: price, date: date)

        artwork.additionalInfo = json["additional_information"].string
        artwork.medium = json["medium"].string

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
