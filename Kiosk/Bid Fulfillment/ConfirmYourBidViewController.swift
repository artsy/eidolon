import UIKit
import ECPhoneNumberFormatter
import Moya
import RxSwift
import Action

class ConfirmYourBidViewController: UIViewController {

    private var _number = Variable("")
    let phoneNumberFormatter = ECPhoneNumberFormatter()

    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    @IBOutlet var numberAmountTextField: TextField!
    @IBOutlet var cursor: CursorView!
    @IBOutlet var keypadContainer: KeypadContainerView!
    @IBOutlet var enterButton: UIButton!
    @IBOutlet var useArtsyLoginButton: UIButton!

    private let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    // Need takeUntil because we bind this signal eventually to bidDetails, making us stick around longer than we should!
    lazy var numberSignal: Observable<String> = { self.keypadContainer.stringValueSignal.takeUntil(self.viewWillDisappear) }()
    
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

        numberSignal
            .bindTo(_number)
            .addDisposableTo(rx_disposeBag)

        numberSignal
            .map(toPhoneNumberString)
            .bindTo(numberAmountTextField.rx_text)
            .addDisposableTo(rx_disposeBag)

        let nav = self.fulfillmentNav()

        let optionalNumberSignal = numberSignal.map { number in
            return Optional(number)
        }

        // We don't know if it's a paddle number or a phone number yet, so bind both ¯\_(ツ)_/¯
        [nav.bidDetails.paddleNumber, nav.bidDetails.newUser.phoneNumber].forEach { variable in
            optionalNumberSignal
                .bindTo(variable)
                .addDisposableTo(rx_disposeBag)
        }

        // Does a bidder exist for this phone number?
        //   if so forward to PIN input VC
        //   else send to enter email

        let auctionID = nav.auctionID
        
        let numberIsZeroLengthSignal = numberSignal.map(isZeroLengthString)

        enterButton.rx_action = CocoaAction(enabledIf: numberIsZeroLengthSignal.not(), workFactory: { [weak self] _ in
            guard let me = self else { return empty() }

            let endpoint: ArtsyAPI = ArtsyAPI.FindBidderRegistration(auctionID: auctionID, phone: String(me.number))
            return XAppRequest(endpoint, provider:me.provider).filterStatusCode(400).doError { (error) -> Void in
                guard let me = self else { return }

                // Due to AlamoFire restrictions we can't stop HTTP redirects
                // so to figure out if we got 302'd we have to introspect the
                // error to see if it's the original URL to know if the
                // request succeeded.

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

        })
    }

    func toOpeningBidString(cents:AnyObject!) -> AnyObject! {
        if let dollars = NSNumberFormatter.currencyStringForCents(cents as? Int) {
            return "Enter \(dollars) or more"
        }
        return ""
    }

    func toPhoneNumberString(number: String) -> String {
        if number.characters.count >= 7 {
            return phoneNumberFormatter.stringForObjectValue(number) ?? number
        } else {
            return number
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
