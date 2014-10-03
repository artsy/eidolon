import UIKit

public class Button: ARFlatButton {

    public override func  setup() {
        super.setup()
        setTitleShadowColor(UIColor.clearColor(), forState: .Normal)
        setTitleShadowColor(UIColor.clearColor(), forState: .Highlighted)
        setTitleShadowColor(UIColor.clearColor(), forState: .Disabled)
        shouldDimWhenDisabled = false;
    }
}

public class ActionButton: Button {

    public override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, 50)
    }

    public override func setup() {
        super.setup()

        setBorderColor(UIColor.blackColor(), forState: .Normal, animated:false)
        setBorderColor(UIColor.artsyPurple(), forState: .Highlighted, animated:false)
        setBorderColor(UIColor.artsyMediumGrey(), forState: .Disabled, animated:false)

        setBackgroundColor(UIColor.blackColor(), forState: .Normal, animated:false)
        setBackgroundColor(UIColor.artsyPurple(), forState: .Highlighted, animated:false)
        setBackgroundColor(UIColor.whiteColor(), forState: .Disabled, animated:false)

        setTitleColor(UIColor.whiteColor(), forState:.Normal)
        setTitleColor(UIColor.whiteColor(), forState:.Highlighted)
        setTitleColor(UIColor.artsyHeavyGrey(), forState:.Disabled)
    }
}

public class KeypadButton: Button {

    public override func setup() {
        super.setup()
        shouldAnimateStateChange = false;
        layer.borderWidth = 0
        setBackgroundColor(UIColor.blackColor(), forState: .Highlighted, animated:false)
        setBackgroundColor(UIColor.whiteColor(), forState: .Normal, animated:false)
    }
}

public class LargeKeypadButton: KeypadButton {
    public override func setup() {
        super.setup()
        self.titleLabel!.font = UIFont.sansSerifFontWithSize(20)
    }
}
