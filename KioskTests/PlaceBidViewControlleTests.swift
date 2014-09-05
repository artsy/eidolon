import Quick
import Nimble
import Kiosk

class PlaceBidViewControllerTests: QuickSpec {
    override func spec() {

        it("looks right by default") {
            let sut  = UIStoryboard(name: "Fulfillment", bundle: nil).instantiateViewControllerWithIdentifier("PlaceBidViewController") as PlaceBidViewController
            
            expect(sut).to( recordSnapshot() )
        }

    }
}
