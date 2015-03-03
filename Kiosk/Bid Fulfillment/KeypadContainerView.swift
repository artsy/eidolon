import UIKit
import Foundation
import ReactiveCocoa

//@IBDesignable
public class KeypadContainerView: UIView {
    private var keypad: KeypadView!
    private let viewModel = KeypadViewModel()
    
    public var stringValueSignal: RACSignal!
    public var intValueSignal: RACSignal!
    public var deleteCommand: RACCommand!
    public var resetCommand: RACCommand!

    override public func prepareForInterfaceBuilder() {
        for subview in subviews as [UIView] { subview.removeFromSuperview() }

        let bundle = NSBundle(forClass: self.dynamicType)
        let image  = UIImage(named: "KeypadViewPreviewIB", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)
        let imageView = UIImageView(frame: self.bounds)
        imageView.image = image

        self.addSubview(imageView)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        
        keypad = NSBundle(forClass: self.dynamicType).loadNibNamed("KeypadView", owner: self, options: nil).first as? KeypadView
        keypad.leftCommand = viewModel.deleteCommand
        keypad.rightCommand = viewModel.clearCommand
        keypad.keyCommand = viewModel.addDigitCommand
        
        intValueSignal = viewModel.intValueSignal.publish().autoconnect()
        stringValueSignal = viewModel.stringValueSignal.publish().autoconnect()
        deleteCommand = viewModel.deleteCommand
        resetCommand = viewModel.clearCommand
        
        self.addSubview(keypad)
    }
}
