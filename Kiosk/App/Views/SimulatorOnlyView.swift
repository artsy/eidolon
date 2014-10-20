import UIKit

class DeveloperOnlyView: UIView {

    override func awakeFromNib() {
        let shouldShow = AppSetup.sharedState.showDebugButtons && AppSetup.sharedState.useStaging
        let notTests = NSClassFromString("XCTest") == nil
        self.hidden = !shouldShow && notTests
    }
}