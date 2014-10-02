import UIKit
import Foundation

//@IBDesignable
public class KeypadContainerView: UIView {

    var keypad:KeypadView?;

    override public func prepareForInterfaceBuilder() {
        for subview in subviews as [UIView] { subview.removeFromSuperview() }

        let bundle = NSBundle(forClass: self.dynamicType)
        let image  = UIImage(named: "KeypadViewPreviewIB", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)
        let imageView = UIImageView(frame: self.bounds)
        imageView.image = image

        self.addSubview(imageView)
    }

    override public func awakeFromNib() {

        keypad = NSBundle(forClass: self.dynamicType).loadNibNamed("KeypadView", owner: self, options: nil).first as? KeypadView
        self.addSubview(keypad!)
    }

}
