import Quick
import Nimble

class ListingsViewControllerTests: QuickSpec {
    let imageCache = SDImageCache.sharedImageCache()
    override func spec() {
        beforeEach {
            Provider.sharedProvider = Provider.StubbingProvider()
            
            let image = UIImage.testImage(named: "artwork", ofType: "jpg")
            
            let urls = [
                "http://stagic3.artsy.net/additional_images/527c19f7a09a677dea000374/large.jpg",
                "http://stagic1.artsy.net/additional_images/52570f80275b24468c000506/large.jpg",
                "http://stagic1.artsy.net/additional_images/5277e3e4cd530eb866000260/1/large.jpg",
                "http://stagic2.artsy.net/additional_images/5277f91dc9dc242b0a000156/1/large.jpg",
                "http://stagic3.artsy.net/additional_images/526ab701c9dc24668f00011e/large.jpg"
            ]
            urls.map { self.imageCache.storeImage(image, forKey: $0) }
        }
        
        afterEach {
            self.imageCache.clearMemory()
            self.imageCache.clearDisk()
        }
        
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
        
        it("looks correct when displaying stubbed contents.") {
            let sut = ListingsViewController()
            
            let selectedIndexSignal = RACSubject()
            sut.switchView.selectedIndexSignal = selectedIndexSignal
            
            sut.beginAppearanceTransition(true, animated: false)
            sut.endAppearanceTransition()
            
            selectedIndexSignal.sendNext(0)
            expect(sut).to(haveValidSnapshot(named: "grid"))
            
            selectedIndexSignal.sendNext(1)
            expect(sut).to(haveValidSnapshot(named: "least bids"))
            
            selectedIndexSignal.sendNext(2)
            expect(sut).to(haveValidSnapshot(named: "most bids"))
            
            selectedIndexSignal.sendNext(3)
            expect(sut).to(haveValidSnapshot(named: "highest bid"))
            
            selectedIndexSignal.sendNext(4)
            expect(sut).to(haveValidSnapshot(named: "lowest bid"))
            
            selectedIndexSignal.sendNext(5)
            expect(sut).to(haveValidSnapshot(named: "alphabetical"))
        }
    }
}
