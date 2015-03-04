import UIKit
import ReactiveCocoa
import Swift_RAC_Macros

public class KeypadView: UIView {
    public dynamic var leftCommand: RACCommand?
    public dynamic var rightCommand: RACCommand?
    public dynamic var keyCommand: RACCommand?

    @IBOutlet private var keys: [Button]!
    @IBOutlet private var leftButton: Button!
    @IBOutlet private var rightButton: Button!

    public override func awakeFromNib() {
        RAC(leftButton, "rac_command") <~ RACObserve(self, "leftCommand")
        RAC(rightButton, "rac_command") <~ RACObserve(self, "rightCommand")
    }
    
    @IBAction func keypadButtonTapped(sender: UIButton) {
        keyCommand?.execute(sender.tag)
    }
}
