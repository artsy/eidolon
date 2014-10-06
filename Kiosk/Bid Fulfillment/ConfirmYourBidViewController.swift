import UIKit


class ConfirmYourBidViewController: UIViewController {

    dynamic var number: String = ""
    let phoneNumberFormatter = ECPhoneNumberFormatter()

    @IBOutlet var numberAmountTextField: UITextField!
    @IBOutlet var keypadContainer: KeypadContainerView!

    class func instantiateFromStoryboard() -> ConfirmYourBidViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBid) as ConfirmYourBidViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let numberIsZeroLengthSignal = RACObserve(self, "number").map({ (number) -> AnyObject! in
            let number = number as String
            return (number.utf16Count == 0)
        })

        RAC(enterButton, "enabled") <~ numberIsZeroLengthSignal.notEach()
        RAC(numberAmountTextField, "text") <~ RACObserve(self, "number").map(toPhoneNumberString)

        keypadSignal.subscribeNext({ [weak self] (input) -> Void in
            let input = String(input as Int)
            let newNumber = self?.number.stringByAppendingString(input)
            self?.number = newNumber!
        })
    }

    @IBOutlet var enterButton: UIButton!
    @IBAction func enterButtonTapped(sender: AnyObject) {

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

    lazy var keypadSignal:RACSignal! = self.keypadContainer.keypad?.keypadSignal
}


private extension ConfirmYourBidViewController {

    func toOpeningBidString(cents:AnyObject!) -> AnyObject! {
        if let dollars = NSNumberFormatter.currencyStringForCents(cents as? Int) {
            return "Enter \(dollars) or more"
        }
        return ""
    }

    func toPhoneNumberString(number:AnyObject!) -> AnyObject! {
        return self.phoneNumberFormatter.stringForObjectValue(number as String)
    }

    @IBAction func dev_noPhoneNumberFoundTapped(sender: AnyObject) {
        self.performSegue(.ConfirmyourBidBidderNotFound)
    }

    @IBAction func dev_phoneNumberFoundTapped(sender: AnyObject) {
        self.performSegue(.ConfirmyourBidBidderFound)
    }

}