import Quick
import Nimble
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
        let data:[String: AnyObject] =  ["id":id , "title" : title, "date":date, "blurb":blurb, "artist":artistDict]

        var artwork: Artwork!

        beforeEach {
            artwork = Artwork.fromJSON(data) as Artwork
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
                ]) as Image
            let otherImage = Image.fromJSON([
                "id": "nonDefault",
                "image_url":"http://image.com/:version.jpg",
                "image_versions" : ["small"],
                "original_width": size.width,
                "original_height": size.height
            ]) as Image

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
            ]) as Image
            let otherImage = Image.fromJSON([
                "id": "nonDefault",
                "image_url":"http://image.com/:version.jpg",
                "image_versions" : ["small"],
                "original_width": size.width,
                "original_height": size.height
            ]) as Image

            artwork.images = [image, otherImage]

            expect(artwork.defaultImage!.id) == "default"
        }
    }
}
