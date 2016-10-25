import Quick
import Nimble
@testable
import Kiosk

let size = CGSize(width: 100, height: 100)

class ImageTests: QuickSpec {
    override func spec() {
        let id = "wah-wah"
        let url = "http://url.com"

        it("converts from JSON") {

            let imageFormats = ["big", "small", "patch"]
            let data:[String: Any] = [ "id": id as AnyObject, "image_url": url, "image_versions": imageFormats, "original_width": size.width, "original_height": size.height]

            let image = Image.fromJSON(data)

            expect(image.id) == id
            expect(image.imageFormatString) == url
            expect(image.imageVersions.count) == imageFormats.count
            expect(image.imageSize) == size
        }

        it("generates a thumbnail url") {
            var image = self.image(forVersion: "large")
            expect(image.thumbnailURL()).toNot( beNil() )

            image = self.image(forVersion: "medium")
            expect(image.thumbnailURL()).toNot( beNil() )

            image = self.image(forVersion: "larger")
            expect(image.thumbnailURL()).toNot( beNil() )
        }

        it("handles unknown image formats"){
            let image = self.image(forVersion: "unknown")
            expect(image.thumbnailURL()).to(beNil())
        }

        it("handles incorrect image_versions JSON") {
            let data:[String: Any] = [ "id": id, "image_url": url, "image_versions": "something invalid"]

            expect(Image.fromJSON(data)).toNot( throwError() )
        }

        it("assumes it's not default if not specified") {
            let image = Image.fromJSON([
                "id": "",
                "image_url":"http://image.com/:version.jpg",
                "image_versions" : ["small"],
                "original_width": size.width,
                "original_height": size.height
            ])

            expect(image.isDefault) == false
        }
    }

    func image(forVersion version:String) -> Image {
        return Image.fromJSON([
            "id": "",
            "image_url":"http://image.com/:version.jpg",
            "image_versions" : [version],
            "original_width": size.width,
            "original_height": size.height
        ])
    }
}
