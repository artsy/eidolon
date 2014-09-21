import UIKit

public class KeypadView: UIView {
    public let keypadSignal = RACSubject()
    public let leftSignal = RACSubject()
    public let rightSignal = RACSubject()

    @IBOutlet var keys: [Button]!
    @IBOutlet public var leftButton: Button!
    @IBOutlet public var rightButton: Button!

    @IBAction func keypadButtonTapped(sender: UIButton) {
        keypadSignal.sendNext(sender.tag)
    }

    @IBAction func rightButtonTapped(sender: UIButton) {
        rightSignal.sendNext(nil)
    }

    @IBAction func leftButtonTapped(sender: UIButton) {
        leftSignal.sendNext(nil)
    }

}
