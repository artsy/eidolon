import Quick
import Nimble
import Kiosk

class SaleArtworkTests: QuickSpec {
    override func spec() {
        describe("estimates") {
            var saleArtwork: SaleArtwork!
            beforeEach {

                let artwork = Artwork.fromJSON([:]) as! Artwork
                saleArtwork = SaleArtwork(id: "id", artwork: artwork)
            }
            
            it("gives no estimtates when no estimates present") {
                expect(saleArtwork.estimateString) == "No Estimate"
            }
            
            it("gives estimtates when low and high are present") {
                saleArtwork.lowEstimateCents = 100_00
                saleArtwork.highEstimateCents = 200_00
                expect(saleArtwork.estimateString) == "Estimate: $100–$200"
            }
            
            it("gives estimtates when low is present") {
                saleArtwork.lowEstimateCents = 100_00
                expect(saleArtwork.estimateString) == "Estimate: $100"
            }
            
            it("gives estimtates when high is present") {
                saleArtwork.highEstimateCents = 200_00
                expect(saleArtwork.estimateString) == "Estimate: $200"
            }
        }
    }
}
