import UIKit
import QuartzCore
import Artsy_UIButtons

class Button: ARFlatButton {

    override func setup() {
        super.setup()
        setTitleShadowColor(UIColor.clear, for: UIControlState())
        setTitleShadowColor(UIColor.clear, for: .highlighted)
        setTitleShadowColor(UIColor.clear, for: .disabled)
        shouldDimWhenDisabled = false;
    }
}

class ActionButton: Button {

    override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: ButtonHeight)
    }

    override func setup() {
        super.setup()

        setBorderColor(.black, for: UIControlState(), animated: false)
        setBorderColor(.artsyPurple(), for: .highlighted, animated: false)
        setBorderColor(.artsyMediumGrey(), for: .disabled, animated: false)

        setBackgroundColor(.black, for: UIControlState(), animated: false)
        setBackgroundColor(.artsyPurple(), for: .highlighted, animated: false)
        setBackgroundColor(.white, for: .disabled, animated: false)

        setTitleColor(.white, for:UIControlState())
        setTitleColor(.white, for:.highlighted)
        setTitleColor(.artsyHeavyGrey(), for:.disabled)
    }
}

class SecondaryActionButton: Button {

    override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: ButtonHeight)
    }

    override func setup() {
        super.setup()

        setBorderColor(.artsyMediumGrey(), for: UIControlState(), animated: false)
        setBorderColor(.artsyPurple(), for: .highlighted, animated: false)
        setBorderColor(.artsyLightGrey(), for: .disabled, animated: false)

        setBackgroundColor(.white, for: UIControlState(), animated: false)
        setBackgroundColor(.artsyPurple(), for: .highlighted, animated: false)
        setBackgroundColor(.white, for: .disabled, animated: false)

        setTitleColor(.black, for:UIControlState())
        setTitleColor(.white, for:.highlighted)
        setTitleColor(.artsyHeavyGrey(), for:.disabled)
    }
}


class KeypadButton: Button {

    override func setup() {
        super.setup()
        shouldAnimateStateChange = false;
        layer.borderWidth = 0
        setBackgroundColor(.black, for: .highlighted, animated: false)
        setBackgroundColor(.white, for: UIControlState(), animated: false)
    }
}

class LargeKeypadButton: KeypadButton {
    override func setup() {
        super.setup()
        self.titleLabel!.font = UIFont.sansSerifFont(withSize: 20)
    }
}

class MenuButton: ARMenuButton {
    override func setup() {
        super.setup()
        if let titleLabel = titleLabel {
            titleLabel.font = titleLabel.font.withSize(12)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let titleLabel = titleLabel { self.bringSubview(toFront: titleLabel) }
        if let imageView = imageView { self.bringSubview(toFront: imageView) }
    }

    override var intrinsicContentSize : CGSize {
        return CGSize(width: 45, height: 45)
    }
}
