import Quick
import Nimble
@testable
import Kiosk

class ArtistTests: QuickSpec {
    override func spec() {

        it("converts from JSON") {

            let id = "artist-1"
            let name = "Artist 1"
            let data = ["id" : id, "name": name]

            let artist = Artist.fromJSON(data)

            expect(artist.id) == id
            expect(artist.name) == name
        }

    }
}
