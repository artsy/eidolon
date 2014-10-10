import Quick
import Nimble

class WebViewControllerTests: QuickSpec {
    override func spec() {
        var sut: WebViewController!
        beforeEach {
            let url = NSURL(fileURLWithPath: NSBundle(forClass: self.dynamicType).pathForResource("test_webpage", ofType: "html")!)!
            sut = WebViewController.instantiateFromStoryboard(url)
        }
        pending("looks correct") { // view doesn't have any content in tests, must fix.
            sut.loadViewProgrammatically()
            expect(sut).to(haveValidSnapshot(named: "instantiate from storyboard"))
        }
    }
}
