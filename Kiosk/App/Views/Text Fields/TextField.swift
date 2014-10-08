import UIKit

public class TextField: UITextField {

    public var shouldAnimateStateChange: Bool = true

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override public init(){
        super.init()
        setup()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        borderStyle = .None
        layer.cornerRadius = 0
        layer.masksToBounds = true
        layer.borderWidth = 1
        tintColor = UIColor.artsyPurple()
        stateChangedAnimated(false)
        setupEvents()
    }

    func setupEvents () {
        addTarget(self, action: "editingDidBegin:", forControlEvents: .EditingDidBegin)
        addTarget(self, action: "editingDidFinish:", forControlEvents: .EditingDidEnd)
    }

    func editingDidBegin (sender: AnyObject) {
        stateChangedAnimated(shouldAnimateStateChange)
    }

    func editingDidFinish(sender: AnyObject) {
        stateChangedAnimated(shouldAnimateStateChange)
    }

    func stateChangedAnimated(animated: Bool) {
        let newBorderColor = borderColorForState()
        if animated {
            let fade = CABasicAnimation()
            if (layer.borderColor == nil) { layer.borderColor = UIColor.clearColor().CGColor }
            fade.fromValue = self.layer.borderColor
            fade.toValue = newBorderColor.CGColor
            fade.duration = AnimationDuration.Short
            layer.addAnimation(fade, forKey: "borderColor")
        }
        layer.borderColor = newBorderColor.CGColor
    }

    func borderColorForState() -> UIColor {
        if (editing) {
            return UIColor.artsyPurple()
        } else {
            return UIColor.artsyMediumGrey()
        }
    }

    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset( bounds, 5, 0 )
    }

    override public func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset( bounds, 5 , 0 )
    }
}

public class SecureTextField: TextField {

    var actualText: String = NSString()

    override public var text: String! {
        get {
            if (editing) {
                return super.text
            } else {
                return actualText;
            }
        }

        set {
            super.text=(newValue)
        }
    }

    override func setup() {
        super.setup()
        clearsOnBeginEditing = true
    }

    override func setupEvents () {
        super.setupEvents()
        addTarget(self, action: "editingDidChange:", forControlEvents: .EditingChanged)
    }

    override func editingDidBegin (sender: AnyObject) {
        super.editingDidBegin(sender)
        secureTextEntry = true
        actualText = text
    }

    func editingDidChange(sender: AnyObject) {
        actualText = text;
    }

    override func editingDidFinish(sender: AnyObject) {
        super.editingDidFinish(sender)
        secureTextEntry = false
        actualText = text;
        text = dotPlaceholder();
    }

    func dotPlaceholder() -> String {
        var index = 0;
        let dots = NSMutableString();
        while (index < countElements(text)) {
            dots.appendString("•");
            index++;
        }
        return dots;
    }
}