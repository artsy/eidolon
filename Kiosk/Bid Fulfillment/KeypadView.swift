import UIKit
import RxSwift
import Action

class KeypadView: UIView {
    var leftAction: CocoaAction? {
        didSet {
            self.leftButton.rx_action = leftAction
        }
    }
    var rightAction: CocoaAction? {
        didSet {
            self.rightButton.rx_action = rightAction
        }
    }

    var keyAction: Action<Int, Void>?

    @IBOutlet private var keys: [Button]!
    @IBOutlet private var leftButton: Button!
    @IBOutlet private var rightButton: Button!
    
    @IBAction func keypadButtonTapped(sender: UIButton) {
        keyAction?.execute(sender.tag)
    }
}
