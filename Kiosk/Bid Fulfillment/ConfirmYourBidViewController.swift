import UIKit
import ECPhoneNumberFormatter
import Moya
import RxSwift
import Action

class ConfirmYourBidViewController: UIViewController {

    fileprivate var _number = Variable("")
    let phoneNumberFormatter = ECPhoneNumberFormatter()

    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!
    @IBOutlet var numberAmountTextField: TextField!
    @IBOutlet var cursor: CursorView!
    @IBOutlet var keypadContainer: KeypadContainerView!
    @IBOutlet var enterButton: UIButton!
    @IBOutlet var useArtsyLoginButton: UIButton!

    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    // Need takeUntil because we bind this observable eventually to bidDetails, making us stick around longer than we should!
    lazy var number: Observable<String> = { self.keypadContainer.stringValue.takeUntil(self.viewWillDisappear) }()

    var provider: Networking!

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> ConfirmYourBidViewController {
        return storyboard.viewController(withID: .ConfirmYourBid) as! ConfirmYourBidViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleString = useArtsyLoginButton.title(for: useArtsyLoginButton.state)!
        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
            NSAttributedStringKey.font: useArtsyLoginButton.titleLabel!.font
        ]
        let attrTitle = NSAttributedString(string: titleString, attributes:attributes)
        useArtsyLoginButton.setAttributedTitle(attrTitle, for:useArtsyLoginButton.state)

        number
            .bind(to: _number)
            .disposed(by: rx.disposeBag)

        number
            .map(toPhoneNumberString)
            .bind(to: numberAmountTextField.rx.text)
            .disposed(by: rx.disposeBag)

        let nav = self.fulfillmentNav()

        bidDetailsPreviewView.bidDetails = nav.bidDetails

        let optionalNumber = number.mapToOptional()

        // We don't know if it's a paddle number or a phone number yet, so bind both ¯\_(ツ)_/¯
        [nav.bidDetails.paddleNumber, nav.bidDetails.newUser.phoneNumber].forEach { variable in
            optionalNumber
                .bind(to: variable)
                .disposed(by: rx.disposeBag)
        }

        // Does a bidder exist for this phone number?
        //   if so forward to PIN input VC
        //   else send to enter email

        let auctionID = nav.auctionID ?? ""
        
        let numberIsZeroLength = number.map(isZeroLength)

        enterButton.rx.action = CocoaAction(enabledIf: numberIsZeroLength.not(), workFactory: { [weak self] _ in
            guard let me = self else { return .empty() }

            let endpoint = ArtsyAPI.findBidderRegistration(auctionID: auctionID, phone: String(me._number.value))

            return me.provider.request(endpoint)
                .filter(statusCode: 400)
                .map(void)
                .do(onError: { error in
                    guard let me = self else { return }

                    // Due to AlamoFire restrictions we can't stop HTTP redirects
                    // so to figure out if we got 302'd we have to introspect the
                    // error to see if it's the original URL to know if the
                    // request succeeded.

                    var response: Moya.Response?

                    if case .statusCode(let receivedResponse)? = error as? MoyaError {
                        response = receivedResponse
                    }

                    if let responseURL = response?.response?.url?.absoluteString
                        , responseURL.contains("v1/bidder/") {

                        me.performSegue(.ConfirmyourBidBidderFound)
                    } else {
                        me.performSegue(.ConfirmyourBidBidderNotFound)
                    }
                })
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        _viewWillDisappear.onNext(Void())
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue == .ConfirmyourBidBidderFound {
            let nextViewController = segue.destination as! ConfirmYourBidPINViewController
            nextViewController.provider = provider
        } else if segue == .ConfirmyourBidBidderNotFound {
            let viewController = segue.destination as! ConfirmYourBidEnterYourEmailViewController
            viewController.provider = provider
        } else if segue == .ConfirmyourBidArtsyLogin {
            let viewController = segue.destination as! ConfirmYourBidArtsyLoginViewController
            viewController.provider = provider
        } else if segue == .ConfirmyourBidBidderFound {
            let viewController = segue.destination as! ConfirmYourBidPINViewController
            viewController.provider = provider
        }
    }

    func toPhoneNumberString(_ number: String) -> String {
        if number.count >= 7 {
            return phoneNumberFormatter.string(for: number) ?? number
        } else {
            return number
        }
    }
}

private extension ConfirmYourBidViewController {


    @IBAction func dev_noPhoneNumberFoundTapped(_ sender: AnyObject) {
        self.performSegue(.ConfirmyourBidArtsyLogin )
    }

    @IBAction func dev_phoneNumberFoundTapped(_ sender: AnyObject) {
        self.performSegue(.ConfirmyourBidBidderFound)
    }

}
