import Quick
import Nimble

class WebViewControllerTests: QuickSpec {
    var sut: WebViewController!
    override func spec() {
        beforeEach {
            sut = WebViewController.instantiateFromStoryboard(url: NSURL(fileURLWithPath: NSBundle(forClass: self.dynamicType).pathForResource("test_webpage", ofType: "html")))
        }
        it("looks correct") {
            expect(sut).to(haveValidSnapshot(named: "instantiate from storyboard"))
        }
    }
}
