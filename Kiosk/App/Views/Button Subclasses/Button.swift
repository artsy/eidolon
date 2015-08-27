import UIKit
import QuartzCore
import Artsy_UIButtons

class Button: ARFlatButton {

    override func setup() {
        super.setup()
        setTitleShadowColor(UIColor.clearColor(), forState: .Normal)
        setTitleShadowColor(UIColor.clearColor(), forState: .Highlighted)
        setTitleShadowColor(UIColor.clearColor(), forState: .Disabled)
        shouldDimWhenDisabled = false;
    }
}

class ActionButton: Button {

    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, ButtonHeight)
    }

    override func setup() {
        super.setup()

        setBorderColor(UIColor.blackColor(), forState: .Normal, animated: false)
        setBorderColor(UIColor.artsyPurple(), forState: .Highlighted, animated: false)
        setBorderColor(UIColor.artsyMediumGrey(), forState: .Disabled, animated: false)

        setBackgroundColor(UIColor.blackColor(), forState: .Normal, animated: false)
        setBackgroundColor(UIColor.artsyPurple(), forState: .Highlighted, animated: false)
        setBackgroundColor(UIColor.whiteColor(), forState: .Disabled, animated: false)

        setTitleColor(UIColor.whiteColor(), forState:.Normal)
        setTitleColor(UIColor.whiteColor(), forState:.Highlighted)
        setTitleColor(UIColor.artsyHeavyGrey(), forState:.Disabled)
    }
}

class SecondaryActionButton: Button {

    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, ButtonHeight)
    }

    override func setup() {
        super.setup()

        setBorderColor(UIColor.artsyMediumGrey(), forState: .Normal, animated: false)
        setBorderColor(UIColor.artsyPurple(), forState: .Highlighted, animated: false)
        setBorderColor(UIColor.artsyLightGrey(), forState: .Disabled, animated: false)

        setBackgroundColor(UIColor.whiteColor(), forState: .Normal, animated: false)
        setBackgroundColor(UIColor.artsyPurple(), forState: .Highlighted, animated: false)
        setBackgroundColor(UIColor.whiteColor(), forState: .Disabled, animated: false)

        setTitleColor(UIColor.blackColor(), forState:.Normal)
        setTitleColor(UIColor.whiteColor(), forState:.Highlighted)
        setTitleColor(UIColor.artsyHeavyGrey(), forState:.Disabled)
    }
}


class KeypadButton: Button {

    override func setup() {
        super.setup()
        shouldAnimateStateChange = false;
        layer.borderWidth = 0
        setBackgroundColor(UIColor.blackColor(), forState: .Highlighted, animated: false)
        setBackgroundColor(UIColor.whiteColor(), forState: .Normal, animated: false)
    }
}

class LargeKeypadButton: KeypadButton {
    override func setup() {
        super.setup()
        self.titleLabel!.font = UIFont.sansSerifFontWithSize(20)
    }
}

class MenuButton: ARMenuButton {
    override func setup() {
        super.setup()
        if let titleLabel = titleLabel {
            titleLabel.font = titleLabel.font.fontWithSize(12)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let titleLabel = titleLabel { self.bringSubviewToFront(titleLabel) }
        if let imageView = imageView { self.bringSubviewToFront(imageView) }
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 45, height: 45)
    }
}
