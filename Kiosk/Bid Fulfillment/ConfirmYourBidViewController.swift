import UIKit
import ECPhoneNumberFormatter
import Moya
import ReactiveCocoa
import Swift_RAC_Macros

public class ConfirmYourBidViewController: UIViewController {

    private dynamic var number: String = ""
    let phoneNumberFormatter = ECPhoneNumberFormatter()

    @IBOutlet public var bidDetailsPreviewView: BidDetailsPreviewView!
    @IBOutlet public var numberAmountTextField: TextField!
    @IBOutlet public var cursor: CursorView!
    @IBOutlet public var keypadContainer: KeypadContainerView!
    @IBOutlet public var enterButton: UIButton!
    @IBOutlet public var useArtsyLoginButton: UIButton!
    
    public lazy var numberSignal: RACSignal = { self.keypadContainer.stringValueSignal }()
    
    public lazy var provider: ArtsyProvider<ArtsyAPI> = Provider.sharedProvider

    class public func instantiateFromStoryboard(storyboard: UIStoryboard) -> ConfirmYourBidViewController {
        return storyboard.viewControllerWithID(.ConfirmYourBid) as! ConfirmYourBidViewController
    }

    override public func viewDidLoad() {
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

        RAC(nav.bidDetails.newUser, "phoneNumber") <~ numberStringSignal
        RAC(nav.bidDetails, "paddleNumber") <~ numberStringSignal
        
        bidDetailsPreviewView.bidDetails = nav.bidDetails

        // Does a bidder exist for this phone number?
        //   if so forward to PIN input VC
        //   else send to enter email


        if let nav = self.navigationController as? FulfillmentNavigationController {
            
            let numberIsZeroLengthSignal = numberStringSignal.map(isZeroLengthString)
            enterButton.rac_command = RACCommand(enabled: numberIsZeroLengthSignal.not()) { [weak self] _ in
                if (self == nil) {
                    return RACSignal.empty()
                }

                let endpoint: ArtsyAPI = ArtsyAPI.FindBidderRegistration(auctionID: nav.auctionID!, phone: String(self!.number))
                return XAppRequest(endpoint, provider:self!.provider).filterStatusCode(400).doError { (error) -> Void in

                    // Due to AlamoFire restrictions we can't stop HTTP redirects
                    // so to figure out if we got 302'd we have to introspect the
                    // error to see if it's the original URL to know if the
                    // request suceedded

                    let moyaResponse = error.userInfo["data"] as? MoyaResponse
                    let responseURL = moyaResponse?.response?.URL?.absoluteString

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
