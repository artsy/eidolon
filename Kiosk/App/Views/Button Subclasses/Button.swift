import UIKit
import QuartzCore

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

public class CircularBlackButton: ARBlackFlatButton {
    public override func setup() {
        super.setup()
        RACObserve(self, "bounds").subscribeNext{ [weak self] (bounds) -> Void in
            if let layer = self?.layer {
                let width = CGRectGetWidth(layer.bounds)
                let height = CGRectGetHeight(layer.bounds)
                let smallestDimension = min(width, height)
                layer.cornerRadius = smallestDimension / 2.0
            }
        }
        
        if let titleLabel = titleLabel {
            titleLabel.font = titleLabel.font.fontWithSize(12)
        }
        
        layer.borderWidth = 2
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.masksToBounds = true
    }
    
    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 45, height: 45)
    }
}
