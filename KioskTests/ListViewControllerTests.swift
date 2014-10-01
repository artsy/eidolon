import Quick
import Nimble

class ListingsViewControllerTests: QuickSpec {
    override func spec() {
        
        it("presents a view controller when showModal is called") {
            // As it's a UINav it needs to be in the real view herarchy 
            
            let window = UIWindow(frame:UIScreen.mainScreen().bounds)
            let sut = ListingsViewController()
            window.rootViewController = sut
            window.makeKeyAndVisible()

            sut.allowAnimations = false;

            let artwork = Artwork(id: "", dateString: "", title: "", name: "", blurb: "", price: "", date: "")
            let saleArtwork = SaleArtwork(id: "", artwork: artwork)
            sut.presentModalForSaleArtwork(saleArtwork)
            
            expect(sut.presentedViewController!) != nil
        }
        
    }
}
