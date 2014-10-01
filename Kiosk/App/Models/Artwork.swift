import Foundation

class Artwork: JSONAble {
    let id: String

    let dateString: String
    dynamic let title: String
    dynamic let name: String
    dynamic let blurb: String
    dynamic let price: String

    dynamic var artists: [Artist]?
    dynamic var culturalMarker: String?

    dynamic var images: [Image]?

    init(id: String, dateString: String, title: String, name: String, blurb: String, price: String) {
        self.id = id
        self.dateString = dateString
        self.title = title
        self.name = name
        self.blurb = blurb
        self.price = price
    }

    override class func fromJSON(json: [String: AnyObject]) -> JSONAble {
        let json = JSON(object: json)

        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let title = json["title"].stringValue
        let dateString = json["date"].stringValue
        let blurb = json["blurb"].stringValue
        let price = json["price"].stringValue

        let artwork = Artwork(id: id, dateString: dateString, title: title, name: name, blurb: blurb, price: price)

        if let artistDictionary = json["artist"].object as? [String: AnyObject] {
            artwork.artists = [Artist.fromJSON(artistDictionary) as Artist]
        }

        if let imageDicts = json["images"].object as? Array<Dictionary<String, AnyObject>> {
            artwork.images = imageDicts.map({ return Image.fromJSON($0) as Image })
        }

        return artwork
    }

}
