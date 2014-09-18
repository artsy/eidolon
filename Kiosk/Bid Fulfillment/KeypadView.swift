import UIKit


public class KeypadView: UIView {
    public let keypadSignal = RACSubject()
    public let leftSignal = RACSubject()
    public let rightSignal = RACSubject()

    @IBOutlet var keys: [Button]!
    @IBOutlet public var leftButton: Button!
    @IBOutlet public var rightButton: Button!

    @IBAction func keypadButtonTapped(sender: AnyObject) {
        let view = sender as UIButton
        keypadSignal.sendNext(sender.tag)
    }

    @IBAction func rightButtonTapped(sender: AnyObject) {
        rightSignal.sendNext(nil)
    }

    @IBAction func leftButtonTapped(sender: AnyObject) {
        leftSignal.sendNext(nil)
    }

}