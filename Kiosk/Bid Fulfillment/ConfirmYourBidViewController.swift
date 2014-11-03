import UIKit

class ConfirmYourBidViewController: UIViewController {

    dynamic var number: String = ""
    let phoneNumberFormatter = ECPhoneNumberFormatter()

    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    @IBOutlet var numberAmountTextField: TextField!
    @IBOutlet var cursor: CursorView!
    @IBOutlet var keypadContainer: KeypadContainerView!
    @IBOutlet var enterButton: UIButton!
    @IBOutlet var useArtsyLoginButton: UIButton!

    lazy var keypadSignal:RACSignal! = self.keypadContainer.keypad?.keypadSignal
    lazy var clearSignal:RACSignal!  = self.keypadContainer.keypad?.rightSignal
    lazy var deleteSignal:RACSignal! = self.keypadContainer.keypad?.leftSignal
    lazy var provider:ReactiveMoyaProvider<ArtsyAPI> = Provider.sharedProvider

    class func instantiateFromStoryboard() -> ConfirmYourBidViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBid) as ConfirmYourBidViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleString = useArtsyLoginButton.titleForState(useArtsyLoginButton.state)! ?? ""
        var attributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            NSFontAttributeName: useArtsyLoginButton.titleLabel!.font];
        let attrTitle = NSAttributedString(string: titleString, attributes:attributes)
        useArtsyLoginButton.setAttributedTitle(attrTitle, forState:useArtsyLoginButton.state)

        let numberIsZeroLengthSignal = RACObserve(self, "number").map(isZeroLengthString)

        RAC(numberAmountTextField, "text") <~ RACObserve(self, "number").map(toPhoneNumberString)

        keypadSignal.subscribeNext(addDigitToNumber)
        deleteSignal.subscribeNext(deleteDigitFromNumber)
        clearSignal.subscribeNext(clearNumber)

        let nav = self.fulfillmentNav()

        RAC(nav.bidDetails.newUser, "phoneNumber") <~ RACObserve(self, "number")
        RAC(nav.bidDetails, "paddleNumber") <~ RACObserve(self, "number")
        
        bidDetailsPreviewView.bidDetails = nav.bidDetails

        // Does a bidder exist for this phone number?
        //   if so forward to PIN input VC
        //   else send to enter email


        if let nav = self.navigationController as? FulfillmentNavigationController {
            
            enterButton.rac_command = RACCommand(enabled: numberIsZeroLengthSignal.notEach()) { [weak self] _ in
                if (self == nil) {
                    return RACSignal.empty()
                }

                let endpoint: ArtsyAPI = ArtsyAPI.FindBidderRegistration(auctionID: nav.auctionID!, phone: self!.number)
                return XAppRequest(endpoint, provider:self!.provider, parameters:endpoint.defaultParameters).filterStatusCode(400).doError { (error) -> Void in

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
                }
            }
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
        let numberString = number as String
        if countElements(numberString) >= 7 {
            return self.phoneNumberFormatter.stringForObjectValue(numberString)
        } else {
            return numberString
        }
    }
}

private extension ConfirmYourBidViewController {


    @IBAction func dev_noPhoneNumberFoundTapped(sender: AnyObject) {
        self.performSegue(.ConfirmyourBidArtsyLogin )
    }

    @IBAction func dev_phoneNumberFoundTapped(sender: AnyObject) {
        self.performSegue(.ConfirmyourBidBidderFound)
    }

}
