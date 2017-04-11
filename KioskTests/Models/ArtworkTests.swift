import Quick
import Nimble
@testable
import Kiosk

class ArtworkTests: QuickSpec {
    override func spec() {
        let id = "wah-wah"
        let title = "title"
        let date = "late 2014"
        let blurb = "pretty good"

        let artistID = "artist-1"
        let artistName = "Artist 1"

        let artistDict = ["id" : artistID, "name": artistName]
        let data: [String: AnyObject] =  ["id":id as AnyObject , "title" : title as AnyObject, "date":date as AnyObject, "blurb":blurb as AnyObject, "artist":artistDict as AnyObject]

        var artwork: Artwork!

        beforeEach {
            artwork = Artwork.fromJSON(data)
        }

        it("converts from JSON") {
            expect(artwork.id) == id
            expect(artwork.artists?.count) == 1
            expect(artwork.artists?.first?.id) == artistID
        }

        it("grabs the default image") {
            let defaultImage = Image.fromJSON([
                "id": "default",
                "image_url":"http://image.com/:version.jpg",
                "image_versions" : ["small"],
                "original_width": size.width,
                "original_height": size.height,
                "default_image": true
                ])
            let otherImage = Image.fromJSON([
                "id": "nonDefault",
                "image_url":"http://image.com/:version.jpg",
                "image_versions" : ["small"],
                "original_width": size.width,
                "original_height": size.height
            ])

            artwork.images = [defaultImage, otherImage]

            expect(artwork.defaultImage!.id) == "default"
        }

        it("grabs the first image as default if there is no default image specified") {
            let image = Image.fromJSON([
                "id": "default",
                "image_url":"http://image.com/:version.jpg",
                "image_versions" : ["small"],
                "original_width": size.width,
                "original_height": size.height,
            ])
            let otherImage = Image.fromJSON([
                "id": "nonDefault",
                "image_url":"http://image.com/:version.jpg",
                "image_versions" : ["small"],
                "original_width": size.width,
                "original_height": size.height
            ])

            artwork.images = [image, otherImage]

            expect(artwork.defaultImage!.id) == "default"
        }

        it("updates the soldStatus") {
            let newArtwork = Artwork.fromJSON(data)
            newArtwork.soldStatus = true

            artwork.updateWithValues(newArtwork)

            expect(artwork.soldStatus) == true
        }
    }
}
