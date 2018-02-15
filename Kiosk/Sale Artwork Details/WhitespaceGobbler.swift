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

        setContentHuggingPriority(UILayoutPriority(rawValue: 50), for: .vertical)
        setContentHuggingPriority(UILayoutPriority(rawValue: 50), for: .horizontal)
        backgroundColor = .clear
    }

    override var intrinsicContentSize : CGSize {
        return CGSize.zero
    }
}
