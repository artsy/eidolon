import Quick
import Nimble

class SwitchViewSpec: QuickSpec {
    override func spec() {
        it("looks correct configured with two buttons") {
            let titles = ["First title", "Second Title"]
            let switchView = SwitchView(buttonTitles: titles)
            switchView.frame = CGRect(origin: CGPointZero, size: CGSize(width: 400, height: switchView.intrinsicContentSize().height))
            
            expect(switchView).to(haveValidSnapshot())
        }
    }
}
