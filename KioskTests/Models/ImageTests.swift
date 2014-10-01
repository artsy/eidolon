import Quick
import Nimble

class ImageTests: QuickSpec {
    override func spec() {

        it("converts from JSON") {
            let id = "wah-wah"
            let url = "http://url.com"

            let imageFormats = ["big", "small", "patch"]
            let data:[String: AnyObject] = [ "id": id, "image_url": url, "image_versions": imageFormats]

            let image = Image.fromJSON(data) as Image

            expect(image.id) == id
            expect(image.imageFormatString) == url
            expect(image.imageVersions.count) == imageFormats.count
        }

        it("generates a thumbnail url") {
            var image = Image(id: "", imageFormatString: "http://image.com/:version.jpg", imageVersions: ["large"])
            expect(image.thumbnailURL()).to(beAnInstanceOf(NSURL))

            image = Image(id: "", imageFormatString: "http://image.com/:version.jpg", imageVersions: ["medium"])
            expect(image.thumbnailURL()).to(beAnInstanceOf(NSURL))

            image = Image(id: "", imageFormatString: "http://image.com/:version.jpg", imageVersions: ["larger"])
            expect(image.thumbnailURL()).to(beAnInstanceOf(NSURL))
        }

        it("handles unknown image formats"){
            let image = Image(id: "", imageFormatString: "http://image.com/:version.jpg", imageVersions: ["unknown"])
            expect(image.thumbnailURL()).toNot(beAnInstanceOf(NSURL))
        }

    }
}
