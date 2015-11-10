import UIKit
import Foundation
import RxSwift

//@IBDesignable
class KeypadContainerView: UIView {
    private var keypad: KeypadView!
    private let viewModel = KeypadViewModel()
    
    var stringValueSignal: RACSignal!
    var intValueSignal: RACSignal!
    var deleteCommand: RACCommand!
    var resetCommand: RACCommand!

    override func prepareForInterfaceBuilder() {
        for subview in subviews { subview.removeFromSuperview() }

        let bundle = NSBundle(forClass: self.dynamicType)
        let image  = UIImage(named: "KeypadViewPreviewIB", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)
        let imageView = UIImageView(frame: self.bounds)
        imageView.image = image

        self.addSubview(imageView)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        keypad = NSBundle(forClass: self.dynamicType).loadNibNamed("KeypadView", owner: self, options: nil).first as? KeypadView
        keypad.leftCommand = viewModel.deleteCommand
        keypad.rightCommand = viewModel.clearCommand
        keypad.keyCommand = viewModel.addDigitCommand
        
        intValueSignal = viewModel.intValueSignal
        stringValueSignal = viewModel.stringValueSignal
        deleteCommand = viewModel.deleteCommand
        resetCommand = viewModel.clearCommand
        
        self.addSubview(keypad)
    }
}
