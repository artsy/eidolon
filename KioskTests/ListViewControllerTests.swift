import Quick
import Nimble

class ListingsViewControllerTests: QuickSpec {
    override func spec() {
        
        it("presents a view controller when showModal is called") {
            // As it's a UINav it needs to be in the real view herarchy 
            
            let window = UIApplication.sharedApplication().delegate!.window!
            let sut = ListingsViewController()
            window!.rootViewController = sut

            sut.allowAnimations = false;

            let artwork = Artwork(id: "", dateString: "", title: "", name: "", blurb: "")
            let saleArtwork = SaleArtwork(id: "", artwork: artwork)
            sut.presentModalForSaleArtwork(saleArtwork)
            
            expect(sut.presentedViewController!) != nil
        }
        
    }
}
