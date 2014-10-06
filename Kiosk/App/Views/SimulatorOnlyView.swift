import UIKit

class DeveloperOnlyView: UIView {

    override func awakeFromNib() {
        let isSim = TARGET_IPHONE_SIMULATOR == 1
        let notTests = NSClassFromString("XCTest") != nil
        self.hidden = isSim && notTests
    }
}