import UIKit
import ECPhoneNumberFormatter
import Moya
import ReactiveCocoa
import Swift_RAC_Macros

class ConfirmYourBidViewController: UIViewController {

    private dynamic var number: String = ""
    let phoneNumberFormatter = ECPhoneNumberFormatter()

    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    @IBOutlet var numberAmountTextField: TextField!
    @IBOutlet var cursor: CursorView!
    @IBOutlet var keypadContainer: KeypadContainerView!
    @IBOutlet var enterButton: UIButton!
    @IBOutlet var useArtsyLoginButton: UIButton!
    
    lazy var numberSignal: RACSignal = { self.keypadContainer.stringValueSignal }()
    
    lazy var provider: ArtsyProvider<ArtsyAPI> = Provider.sharedProvider

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> ConfirmYourBidViewController {
        return storyboard.viewControllerWithID(.ConfirmYourBid) as! ConfirmYourBidViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleString = useArtsyLoginButton.titleForState(useArtsyLoginButton.state)! ?? ""
        let attributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            NSFontAttributeName: useArtsyLoginButton.titleLabel!.font];
        let attrTitle = NSAttributedString(string: titleString, attributes:attributes)
        useArtsyLoginButton.setAttributedTitle(attrTitle, forState:useArtsyLoginButton.state)

        RAC(self, "number") <~ numberSignal
        
        let numberStringSignal = RACObserve(self, "number")
        RAC(numberAmountTextField, "text") <~ numberStringSignal.map(toPhoneNumberString)

        let nav = self.fulfillmentNav()

        RAC(nav.bidDetails.newUser, "phoneNumber") <~ numberStringSignal.takeUntil(viewWillDisappearSignal())
        RAC(nav.bidDetails, "paddleNumber") <~ numberStringSignal.takeUntil(viewWillDisappearSignal())
        
        bidDetailsPreviewView.bidDetails = nav.bidDetails

        // Does a bidder exist for this phone number?
        //   if so forward to PIN input VC
        //   else send to enter email


        if let nav = self.navigationController as? FulfillmentNavigationController {
            let auctionID = nav.auctionID
            
            let numberIsZeroLengthSignal = numberStringSignal.map(isZeroLengthString)
            enterButton.rac_command = RACCommand(enabled: numberIsZeroLengthSignal.not()) { [weak self] _ in
                guard let me = self else { return RACSignal.empty() }

                let endpoint: ArtsyAPI = ArtsyAPI.FindBidderRegistration(auctionID: auctionID, phone: String(me.number))
                return XAppRequest(endpoint, provider:me.provider).filterStatusCode(400).doError { (error) -> Void in
                    guard let me = self else { return }

                    // Due to AlamoFire restrictions we can't stop HTTP redirects
                    // so to figure out if we got 302'd we have to introspect the
                    // error to see if it's the original URL to know if the
                    // request suceedded

                    let moyaResponse = error.userInfo["data"] as? MoyaResponse
                    let responseURL = moyaResponse?.response?.URL?.absoluteString

                    if let responseURL = responseURL {
                        if (responseURL as NSString).containsString("v1/bidder/") {
                            me.performSegue(.ConfirmyourBidBidderFound)
                            return
                        }
                    }

                    me.performSegue(.ConfirmyourBidBidderNotFound)
                    return
                }
            }
        }
    }

    func toOpeningBidString(cents:AnyObject!) -> AnyObject! {
        if let dollars = NSNumberFormatter.currencyStringForCents(cents as? Int) {
            return "Enter \(dollars) or more"
        }
        return ""
    }

    func toPhoneNumberString(number:AnyObject!) -> AnyObject! {
        let numberString = number as! String
        if numberString.characters.count >= 7 {
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
