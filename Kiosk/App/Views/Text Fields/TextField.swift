import UIKit

class TextField: UITextField {

    var shouldAnimateStateChange: Bool = true
    var shouldChangeColorWhenEditing: Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        borderStyle = .None
        layer.cornerRadius = 0
        layer.masksToBounds = true
        layer.borderWidth = 1
        tintColor = .blackColor()
        stateChangedAnimated(false)
        setupEvents()
    }

    func setupEvents () {
        addTarget(self, action: #selector(TextField.editingDidBegin(_:)), forControlEvents: .EditingDidBegin)
        addTarget(self, action: #selector(TextField.editingDidFinish(_:)), forControlEvents: .EditingDidEnd)
    }

    func editingDidBegin (sender: AnyObject) {
        stateChangedAnimated(shouldAnimateStateChange)
    }

    func editingDidFinish(sender: AnyObject) {
        stateChangedAnimated(shouldAnimateStateChange)
    }

    func stateChangedAnimated(animated: Bool) {
        let newBorderColor = borderColorForState().CGColor
        if CGColorEqualToColor(newBorderColor, layer.borderColor) {
            return
        }
        if animated {
            let fade = CABasicAnimation()
            if layer.borderColor == nil { layer.borderColor = UIColor.clearColor().CGColor }
            fade.fromValue = self.layer.borderColor ?? UIColor.clearColor().CGColor
            fade.toValue = newBorderColor
            fade.duration = AnimationDuration.Short
            layer.addAnimation(fade, forKey: "borderColor")
        }
        layer.borderColor = newBorderColor
    }

    func borderColorForState() -> UIColor {
        if editing && shouldChangeColorWhenEditing {
            return .artsyPurple()
        } else {
            return .artsyMediumGrey()
        }
    }

    func setBorderColor(color: UIColor){
        self.layer.borderColor = color.CGColor
    }

    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset( bounds, 10, 0 )
    }

    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset( bounds, 10 , 0 )
    }
}

class SecureTextField: TextField {

    var actualText: String = ""

    override var text: String! {
        get {
            if editing {
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
        addTarget(self, action: #selector(SecureTextField.editingDidChange(_:)), forControlEvents: .EditingChanged)
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
        while (index < text.characters.count) {
            dots.appendString("•");
            index += 1;
        }
        return dots as String;
    }
}