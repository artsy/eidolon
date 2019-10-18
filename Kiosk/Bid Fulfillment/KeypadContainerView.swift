import UIKit
import Foundation
import RxSwift
import Action
import FLKAutoLayout

@IBDesignable
class KeypadContainerView: UIView {
    fileprivate var keypad: KeypadView!
    fileprivate let viewModel = KeypadViewModel()
    
    var stringValue: Observable<String>!
    var currencyValue: Observable<Currency>!
    var deleteAction: CocoaAction!
    var addPlusAction: CocoaAction!
    var resetAction: CocoaAction!

    /// Setting this value after the instance has been loaded has no effect.
    /// The value is set in Interface Builder.
    @IBInspectable
    var isPhoneNumberEntry: Bool = false

    override func prepareForInterfaceBuilder() {
        for subview in subviews { subview.removeFromSuperview() }

        let bundle = Bundle(for: type(of: self))
        let image  = UIImage(named: "KeypadViewPreviewIB", in: bundle, compatibleWith: self.traitCollection)
        let imageView = UIImageView(frame: self.bounds)
        imageView.image = image

        self.addSubview(imageView)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        keypad = Bundle(for: type(of: self)).loadNibNamed("KeypadView", owner: self, options: nil)?.first as? KeypadView

        if self.isPhoneNumberEntry {
            keypad.leftAction = viewModel.addPlusAction
            keypad.setLeftButton(.plus)
        } else {
            keypad.leftAction = viewModel.deleteAction
            keypad.setLeftButton(.delete)
        }

        keypad.rightAction = viewModel.clearAction
        keypad.keyAction = viewModel.addDigitAction
        
        currencyValue = viewModel.currencyValue.asObservable()
        stringValue = viewModel.stringValue.asObservable()
        deleteAction = viewModel.deleteAction
        resetAction = viewModel.clearAction
        addPlusAction = viewModel.addPlusAction
        
        self.addSubview(keypad)

        keypad.align(to: self)
    }
}
