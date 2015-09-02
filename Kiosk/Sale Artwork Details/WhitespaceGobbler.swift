import UIKit

class WhitespaceGobbler: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init() {
        self.init(frame: CGRect.zero)

        setContentHuggingPriority(50, forAxis: .Vertical)
        setContentHuggingPriority(50, forAxis: .Horizontal)
        backgroundColor = .clearColor()
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize.zero
    }
}
