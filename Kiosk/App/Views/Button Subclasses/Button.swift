import UIKit

@IBDesignable
public class Button: ARFlatButton {

    public override var enabled: Bool {
        set {
            setEnabled(newValue, animated: false)
        }
        get {
            return super.enabled
        }
    }

    public override var selected: Bool {
        set {
            setSelected(newValue, animated: false)
        }
        get {
            return super.selected
        }
    }
    
    public override var highlighted: Bool {
        set {
            setHighlighted(newValue, animated: false)
        }
        get {
            return super.highlighted
        }
    }
}

public class ActionButton: Button {

    override public func setup() {
        super.setup()
        setBorderColor(UIColor.blackColor(), forState: .Normal, animated:false)
        setBorderColor(UIColor.artsyHeavyGrey(), forState: .Disabled, animated:false)

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
        self.titleLabel!.font = UIFont.sansSerifFontWithSize(20)
    }
}
