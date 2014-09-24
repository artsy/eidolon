import UIKit

class DeveloperOnlyView: UIView {
    override func awakeFromNib() {
        self.hidden = TARGET_IPHONE_SIMULATOR != 0
    }
}
