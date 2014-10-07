import UIKit


class ConfirmYourBidViewController: UIViewController {

    dynamic var number: String = ""
    let phoneNumberFormatter = ECPhoneNumberFormatter()

    @IBOutlet var numberAmountTextField: UITextField!

    @IBOutlet var keypadContainer: KeypadContainerView!
    lazy var keypadSignal:RACSignal! = self.keypadContainer.keypad?.keypadSignal
    lazy var clearSignal:RACSignal!  = self.keypadContainer.keypad?.rightSignal
    lazy var deleteSignal:RACSignal! = self.keypadContainer.keypad?.leftSignal

    class func instantiateFromStoryboard() -> ConfirmYourBidViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBid) as ConfirmYourBidViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let numberIsZeroLengthSignal = RACObserve(self, "number").map({ countElements($0 as String) == 0 })

        RAC(enterButton, "enabled") <~ numberIsZeroLengthSignal.notEach()
        RAC(numberAmountTextField, "text") <~ RACObserve(self, "number").map(toPhoneNumberString)

        keypadSignal.subscribeNext(addDigitToNumber)
        deleteSignal.subscribeNext(deleteDigitFromNumber)
        clearSignal.subscribeNext(clearNumber)
    }

    @IBOutlet var enterButton: UIButton!
    @IBAction func enterButtonTapped(sender: AnyObject) {

        // Does a bidder exist for this phone number?
        //   if so forward to PIN input VC
        //   else send to enter email

        if let nav = self.navigationController as? FulfillmentNavigationController {

            let endpoint: ArtsyAPI = ArtsyAPI.FindBidderRegistration(auctionID: nav.auctionID!, phone: number)
            let bidderRequest = XAppRequest(endpoint).filterStatusCode(400).subscribeNext({ [weak self] (_) -> Void in
            }, error: { [weak self] (error) -> Void in

                // Due to AlamoFire restrictions we can't stop HTTP redirects
                // so to figure out if we got 302'd we have to introspect the
                // error to see if it's the original URL to know if the
                // request suceedded

                let moyaResponse = error.userInfo?["data"] as? MoyaResponse
                let responseURL = moyaResponse?.response?.URL?.absoluteString?

                if let responseURL = responseURL {
                    if (responseURL as NSString).containsString("v1/bidder/") {
                        self?.performSegue(.ConfirmyourBidBidderFound)
                        return
                    }
                }

                self?.performSegue(.ConfirmyourBidBidderNotFound)
                return
            })

        }
    }

    func addDigitToNumber(input:AnyObject!) -> Void {
        self.number = "\(self.number)\(input)"
    }

    func deleteDigitFromNumber(input:AnyObject!) -> Void {
        self.number = dropLast(self.number)
    }

    func clearNumber(input:AnyObject!) -> Void {
        self.number = ""
    }

    func toOpeningBidString(cents:AnyObject!) -> AnyObject! {
        if let dollars = NSNumberFormatter.currencyStringForCents(cents as? Int) {
            return "Enter \(dollars) or more"
        }
        return ""
    }

    func toPhoneNumberString(number:AnyObject!) -> AnyObject! {
        return self.phoneNumberFormatter.stringForObjectValue(number as String)
    }

}

private extension ConfirmYourBidViewController {


    @IBAction func dev_noPhoneNumberFoundTapped(sender: AnyObject) {
        self.performSegue(.ConfirmyourBidBidderNotFound)
    }

    @IBAction func dev_phoneNumberFoundTapped(sender: AnyObject) {
        self.performSegue(.ConfirmyourBidBidderFound)
    }

}