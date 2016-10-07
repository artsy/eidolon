import Quick
import Nimble
@testable
import Kiosk
import Nimble_Snapshots

class SwitchViewSpec: QuickSpec {
    override func spec() {
        it("looks correct configured with two buttons") {
            let titles = ["First title", "Second Title"]
            let switchView = SwitchView(buttonTitles: titles)
            switchView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 400, height: switchView.intrinsicContentSize.height))
            
            expect(switchView).to(haveValidSnapshot(named:"default"))
        }
    }
}
