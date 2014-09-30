import UIKit

@IBDesignable
public class Button: UIButton {

    // These are truncated to fit in IB
    
    @IBInspectable public var normalBGColor: UIColor = UIColor.artsyMediumGrey()
    @IBInspectable public var disabledBGColor: UIColor = UIColor.artsyLightGrey()
    @IBInspectable public var highlightBGColor: UIColor = UIColor.artsyHeavyGrey()
    @IBInspectable public var selectedBGColor: UIColor = UIColor.artsyPurple()
    
    @IBInspectable public var normalBorderColor: UIColor = UIColor.blackColor()
    @IBInspectable public var disabledBorderColor: UIColor = UIColor.artsyLightGrey()
    @IBInspectable public var highlightBorderColor: UIColor = UIColor.blackColor()
    @IBInspectable public var selectedBorderColor: UIColor = UIColor.blackColor()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func awakeFromNib() {
        setup()
    }
    
    func setup() {
        let layer = self.layer;
        layer.masksToBounds = true;
        layer.cornerRadius = 0;
        layer.borderWidth = 2;
        
        self.backgroundColor = UIColor.artsyLightGrey()
        self.titleLabel!.font = UIFont.sansSerifFontWithSize(self.titleLabel!.font.pointSize)
        
        // Ideally I would add a RAC signal thingy for state here
        stateChangedAnimated(false)
    }
    
    override public func setTitle(title: String?, forState state: UIControlState) {
        let fontName = titleLabel!.font.fontName
        if  fontName == "TeXGyreAdventor-Regular" || fontName == "AvantGardeGothicITCW01Dm" {
            super.setTitle(title?.uppercaseString, forState: state)
        } else {
            super.setTitle(title, forState: state)
        }
    }

    func backgroundColorForState(state:UIControlState) -> UIColor {
        
        if state == .Highlighted {
            return highlightBGColor
            
        } else if state == .Disabled {
            return disabledBGColor
            
        } else if state == .Selected {
            return selectedBGColor
        }
        
        return normalBGColor
    }
    
    
    func borderColorForState(state:UIControlState) -> UIColor {
        
        if state == .Highlighted {
            return highlightBorderColor
            
        } else if state == .Disabled {
            return disabledBorderColor
            
        } else if state == .Selected {
            return selectedBorderColor
        }
        
        return normalBorderColor
    }
    
    // Public for testing atm, can change with RAC included
    public func stateChangedAnimated(animate:Bool) {
        let newBackgroundColor = backgroundColorForState(state)
        let newBorderColor:UIColor = borderColorForState(state)
        
        if newBackgroundColor.isEqual(self.layer.backgroundColor) == false {
            if animate {
                let fade = CABasicAnimation()
                fade.fromValue = self.layer.backgroundColor
                fade.toValue = newBackgroundColor.CGColor
                fade.duration = AnimationDuration.Short.rawValue
                layer.addAnimation(fade, forKey: "backgroundColor")
                
            } else {
                layer.backgroundColor = newBackgroundColor.CGColor
            }
        }
        
        if newBorderColor.isEqual(self.layer.borderColor) == false {
            if animate {
                let fade = CABasicAnimation()
                fade.fromValue = self.layer.backgroundColor
                fade.toValue = newBorderColor.CGColor
                fade.duration = AnimationDuration.Short.rawValue
                layer.addAnimation(fade, forKey: "borderColor")
                
            } else {
                layer.borderColor = newBorderColor.CGColor
            }
        }
    }
    
    override public func prepareForInterfaceBuilder() {
        stateChangedAnimated(false)
    }
    
    public override var enabled: Bool {
        didSet {
            stateChangedAnimated(false)
        }
    }

    public override var selected: Bool {
        didSet {
            stateChangedAnimated(false)
        }
    }
    
    public override var highlighted: Bool {
        didSet {
            stateChangedAnimated(false)
        }
    }

    
}

