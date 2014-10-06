import Foundation

public class SwitchView: UIView {
    public var shouldAnimate = true
    public var animationDuration: NSTimeInterval = AnimationDuration.Short
    public let selectedIndexSignal: RACSignal = RACSubject()
    
    private let buttons: Array<UIButton>
    private let selectionIndicator: UIView
    private let topSelectionIndicator: UIView
    private let bottomSelectionIndicator: UIView
    
    var selectionConstraint: NSLayoutConstraint!
    
    public init(buttonTitles: Array<String>) {
        buttons = buttonTitles.map { (buttonTitle: String) -> UIButton in
            var button = UIButton.buttonWithType(.Custom) as UIButton
            
            button.setTitle(buttonTitle, forState: .Normal)
            button.setTitle(buttonTitle, forState: .Disabled)
            
            if let titleLabel = button.titleLabel {
                titleLabel.font = UIFont.sansSerifFontWithSize(14)
                titleLabel.backgroundColor = UIColor.whiteColor()
                titleLabel.opaque = true
            }
            
            button.backgroundColor = UIColor.whiteColor()
            button.setTitleColor(UIColor.blackColor(), forState: .Disabled)
            button.setTitleColor(UIColor.blackColor(), forState: .Selected)
            button.setTitleColor(UIColor.artsyHeavyGrey(), forState: .Normal)
            
            return button
        }
        selectionIndicator = UIView()
        topSelectionIndicator = UIView()
        bottomSelectionIndicator = UIView()
        
        super.init(frame: CGRectZero)
        
        setup()
    }

    required convenience public init(coder aDecoder: NSCoder) {
        self.init(buttonTitles: [])
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 46)
    }
    
    public func selectedButton(button: UIButton!) {
        let index = find(buttons, button)!
        setSelectedIndex(index, animated: shouldAnimate)
    }
}

private extension SwitchView {
    func setup() {       
        if let firstButton = buttons.first {
            firstButton.enabled = false
            (selectedIndexSignal as RACSubject).sendNext(0)
        }
        
        let widthPredicateMultiplier = "*\(widthMultiplier())"
        
        for var i = 0; i < buttons.count; i++ {
            var button = buttons[i]
            
            self.addSubview(button)
            button.addTarget(self, action: "selectedButton:", forControlEvents: .TouchUpInside)
            
            button.constrainWidthToView(self, predicate: widthPredicateMultiplier)
            
            if (i == 0) {
                button.alignLeadingEdgeWithView(self, predicate: nil)
            } else {
                button.constrainLeadingSpaceToView(buttons[i-1], predicate: nil)
            }
            
            button.alignTop("2", bottom: "-2", toView: self)
        }
        
        selectionIndicator.addSubview(topSelectionIndicator)
        selectionIndicator.addSubview(bottomSelectionIndicator)
        
        topSelectionIndicator.backgroundColor = UIColor.blackColor()
        bottomSelectionIndicator.backgroundColor = UIColor.blackColor()
        
        topSelectionIndicator.alignTop("0", leading: "0", bottom: nil, trailing: "0", toView: selectionIndicator)
        bottomSelectionIndicator.alignTop(nil, leading: "0", bottom: "0", trailing: "0", toView: selectionIndicator)
        
        topSelectionIndicator.constrainHeight("2")
        bottomSelectionIndicator.constrainHeight("2")
        
        insertSubview(selectionIndicator, atIndex: 0)
        selectionIndicator.constrainWidthToView(self, predicate: widthPredicateMultiplier)
        selectionIndicator.alignTop("0", bottom: "0", toView: self)
        
        selectionConstraint = selectionIndicator.alignLeadingEdgeWithView(self, predicate: nil).last! as NSLayoutConstraint
    }
    
    func widthMultiplier() -> Float {
        return 1.0 / Float(buttons.count)
    }
    
    func setSelectedIndex(index: Int) {
        setSelectedIndex(index, animated: false)
    }
    
    func setSelectedIndex(index: Int, animated: Bool) {
        UIView.animateIf(shouldAnimate && animated, withDuration: animationDuration, options: .CurveEaseOut) { () -> Void in
            let button = self.buttons[index]
            
            self.buttons.map { (button: UIButton) -> Void in
                button.enabled = true
            }
            
            button.enabled = false
            
            // Set the x-position of the selection indicator as a fraction of the total width of the switch view according to which button was pressed.
            let multiplier = CGFloat(index) / CGFloat(countElements(self.buttons))
            
            self.removeConstraint(self.selectionConstraint)
            self.selectionConstraint = NSLayoutConstraint(item: self.selectionIndicator, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: multiplier, constant: 0)
            self.addConstraint(self.selectionConstraint)
            self.layoutIfNeeded()
            
            (self.selectedIndexSignal as RACSubject).sendNext(index)
        }
    }
}
