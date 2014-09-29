import UIKit

public class ConfirmYourBidViewController: UIViewController {

    dynamic var number: String = ""
    var bid:Bid?
    let phoneNumberFormatter = ECPhoneNumberFormatter()

    @IBOutlet public var numberAmountTextField: UITextField!
    @IBOutlet var keypadContainer: KeypadContainerView!

    public class func instantiateFromStoryboard() -> ConfirmYourBidViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBid) as ConfirmYourBidViewController
    }

    @IBAction public func dev_noPhoneNumberFoundTapped(sender: AnyObject) {
        self.performSegue(.ConfirmyourBidBidderNotFound)
    }

    @IBAction public func dev_phoneNumberFoundTapped(sender: AnyObject) {
        self.performSegue(.ConfirmyourBidBidderFound)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let numberIsZeroLengthSignal = RACObserve(self, "number").map({ (number) -> AnyObject! in
            let number = number as String
            return (number.utf16Count == 0)
        })

        RAC(enterButton, "enabled") <~ numberIsZeroLengthSignal.notEach()
        RAC(numberAmountTextField, "text") <~ RACObserve(self, "number").map({ [weak self](number) -> AnyObject! in
            return self?.phoneNumberFormatter.stringForObjectValue(number)
        })

        keypadSignal.subscribeNext({ [weak self] (input) -> Void in
            let input = String(input as Int)
            let newNumber = self?.number.stringByAppendingString(input)
            self?.number = newNumber!
        })
    }

    @IBOutlet public var enterButton: UIButton!
    @IBAction func enterButtonTapped(sender: AnyObject) {

    }

    lazy public var keypadSignal:RACSignal! = self.keypadContainer.keypad?.keypadSignal
}
