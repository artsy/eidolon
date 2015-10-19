import Quick
import Nimble
@testable
import Kiosk

class SaleArtworkViewModelTests: QuickSpec {
    override func spec() {
        var saleArtwork: SaleArtwork!
        var subject: SaleArtworkViewModel!
        
        beforeEach {
            let artwork = Artwork.fromJSON([:]) as! Artwork
            saleArtwork = SaleArtwork(id: "id", artwork: artwork)
            
            subject = SaleArtworkViewModel(saleArtwork: saleArtwork)
        }
        
        it("shows the correct number of bids") {
            saleArtwork.highestBidCents = 1000_00
            saleArtwork.bidCount = 15
            
            let bidString = subject.numberOfBidsSignal.first() as! String
            
            expect(bidString) == "15 bids placed"
        }
        
        it("shows zero bids if there is no highestBidCents") {
            saleArtwork.bidCount = 1
            
            let bidString = subject.numberOfBidsSignal.first() as! String
            
            expect(bidString) == "0 bids placed"
        }
    }
}
