import UIKit


public class KeypadView: UIView {
    var isInInterfaceBuilder = false

    @IBOutlet var keys: [Button]!
    @IBOutlet var leftButton: Button!
    @IBOutlet var rightButton: Button!

    @IBAction func keypadButtonTapped(sender: AnyObject) {
        // tag = number
    }

    @IBAction func rightButtonTapped(sender: AnyObject) {

    }

    @IBAction func leftButtonTapped(sender: AnyObject) {

    }

}