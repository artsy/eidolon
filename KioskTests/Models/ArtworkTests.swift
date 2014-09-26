import Quick
import Nimble

class ArtworkTests: QuickSpec {
    override func spec() {

        it("converts from JSON") {
            let id = "wah-wah"
            let title = "title"
            let date = "late 2014"
            let blurb = "pretty good"

            let artistID = "artist-1"
            let artistName = "Artist 1"

            let artistDict = ["id" : artistID, "name": artistName]
            let data:[String: AnyObject] =  ["id":id , "title" : title, "date":date, "blurb":blurb, "artist":artistDict]


            let artwork = Artwork.fromJSON(data)

            expect(artwork.id) == id
            expect(artwork.artists?.count) == 1
            expect(artwork.artists?.first?.id) == artistID
        }
    }
}
