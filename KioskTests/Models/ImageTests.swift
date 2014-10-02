import Quick
import Nimble

let size = CGSize(width: 100, height: 100)

class ImageTests: QuickSpec {
    override func spec() {

        it("converts from JSON") {
            let id = "wah-wah"
            let url = "http://url.com"

            let imageFormats = ["big", "small", "patch"]
            let data:[String: AnyObject] = [ "id": id, "image_url": url, "image_versions": imageFormats, "original_width": size.width, "original_height": size.height]

            let image = Image.fromJSON(data) as Image

            expect(image.id) == id
            expect(image.imageFormatString) == url
            expect(image.imageVersions.count) == imageFormats.count
            expect(image.imageSize) == size
        }

        it("generates a thumbnail url") {
            var image = Image(id: "", imageFormatString: "http://image.com/:version.jpg", imageVersions: ["large"], imageSize: size)
            expect(image.thumbnailURL()).to(beAnInstanceOf(NSURL))

            image = Image(id: "", imageFormatString: "http://image.com/:version.jpg", imageVersions: ["medium"], imageSize: size)
            expect(image.thumbnailURL()).to(beAnInstanceOf(NSURL))

            image = Image(id: "", imageFormatString: "http://image.com/:version.jpg", imageVersions: ["larger"], imageSize: size)
            expect(image.thumbnailURL()).to(beAnInstanceOf(NSURL))
        }

        it("handles unknown image formats"){
            let image = Image(id: "", imageFormatString: "http://image.com/:version.jpg", imageVersions: ["unknown"], imageSize: size)
            expect(image.thumbnailURL()).toNot(beAnInstanceOf(NSURL))
        }

    }
}
