import UIKit

class WhitespaceGobbler: UIView {
    override convenience init(frame: CGRect) {
        self.init()
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }

    override init() {
        super.init(frame: CGRect.zeroRect)

        setContentHuggingPriority(50, forAxis: .Vertical)
        setContentHuggingPriority(50, forAxis: .Horizontal)
        backgroundColor = UIColor.clearColor()
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize.zeroSize
    }
}
