import UIKit
import ReactiveCocoa
import Swift_RAC_Macros

class KeypadView: UIView {
    dynamic var leftCommand: RACCommand?
    dynamic var rightCommand: RACCommand?
    dynamic var keyCommand: RACCommand?

    @IBOutlet private var keys: [Button]!
    @IBOutlet private var leftButton: Button!
    @IBOutlet private var rightButton: Button!

    override func awakeFromNib() {
        RAC(leftButton, "rac_command") <~ RACObserve(self, "leftCommand")
        RAC(rightButton, "rac_command") <~ RACObserve(self, "rightCommand")
    }
    
    @IBAction func keypadButtonTapped(sender: UIButton) {
        keyCommand?.execute(sender.tag)
    }
}
