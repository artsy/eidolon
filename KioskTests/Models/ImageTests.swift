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
            expect(image.imageURL) == url
            expect(image.imageVersions.count) == imageFormats.count
        }

    }
}
