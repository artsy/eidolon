import Foundation

class Artwork: JSONAble {
    let id: String

    let dateString: String
    let title: String
    let name: String
    let blurb: String

    var artists: [Artist]?
    var culturalMarker: String?

    var images: [Image]?

    init(id: String, dateString: String, title: String, name: String, blurb: String) {
        self.id = id
        self.dateString = dateString
        self.title = title
        self.name = name
        self.blurb = blurb
    }

    override class func fromJSON(json: [String: AnyObject]) -> JSONAble {
        let json = JSON(object: json)

        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let title = json["title"].stringValue
        let dateString = json["date"].stringValue
        let blurb = json["blurb"].stringValue

        let artwork = Artwork(id: id, dateString: dateString, title: title, name: name, blurb: blurb)

        if let artistDictionary = json["artist"].object as? [String: AnyObject] {
            artwork.artists = [Artist.fromJSON(artistDictionary) as Artist]
        }

        if let imageDicts = json["images"].object as? Array<Dictionary<String, AnyObject>> {
            artwork.images = imageDicts.map({ return Image.fromJSON($0) as Image })
        }

        return artwork
    }

}
