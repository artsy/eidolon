import UIKit

public class Button: ARFlatButton {

    override public func setup() {
        super.setup()
        shouldAnimateStateChange = false;
        shouldDimWhenDisabled = false;
    }
}

public class ActionButton: Button {

    override public func setup() {
        super.setup()

        setTitleShadowColor(UIColor.clearColor(), forState: .Normal)

        setBorderColor(UIColor.blackColor(), forState: .Normal, animated:false)
        setBorderColor(UIColor.artsyMediumGrey(), forState: .Disabled, animated:false)

        setBackgroundColor(UIColor.blackColor(), forState: .Normal, animated:false)
        setBackgroundColor(UIColor.whiteColor(), forState: .Disabled, animated:false)

        setTitleColor(UIColor.whiteColor(), forState:.Normal)
        setTitleColor(UIColor.artsyHeavyGrey(), forState:.Disabled)
    }
}

public class KeypadButton: Button {

    override public func setup() {
        super.setup()
        layer.borderWidth = 0
        setBackgroundColor(UIColor.blackColor(), forState: .Highlighted, animated:false)
        setBackgroundColor(UIColor.whiteColor(), forState: .Normal, animated:false)
    }
}

public class LargeKeypadButton: KeypadButton {
    override public func setup() {
        super.setup()
        self.titleLabel!.font = UIFont.sansSerifFontWithSize(20)
    }
}
