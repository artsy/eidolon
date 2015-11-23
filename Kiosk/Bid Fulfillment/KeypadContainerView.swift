import UIKit
import Foundation
import RxSwift
import Action

//@IBDesignable
class KeypadContainerView: UIView {
    private var keypad: KeypadView!
    private let viewModel = KeypadViewModel()
    
    var stringValue: Observable<String>!
    var intValue: Observable<Int>!
    var deleteAction: CocoaAction!
    var resetAction: CocoaAction!

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
        keypad.leftAction = viewModel.deleteAction
        keypad.rightAction = viewModel.clearAction
        keypad.keyAction = viewModel.addDigitAction
        
        intValue = viewModel.intValue.asObservable()
        stringValue = viewModel.stringValue.asObservable()
        deleteAction = viewModel.deleteAction
        resetAction = viewModel.clearAction
        
        self.addSubview(keypad)
    }
}
