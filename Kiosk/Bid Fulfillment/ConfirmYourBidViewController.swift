import UIKit
import Moya
import RxSwift
import Action

class ConfirmYourBidViewController: UIViewController {
    fileprivate var _number = Variable("")

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

            let endPointGenerator = { (authNumberType: BidDetails.AuthNumberType) -> ArtsyAPI in
                let number = authNumberType == .paddleNumber ? me._number.value : formatPhoneNumberForRegion(me._number.value)
                return ArtsyAPI.findBidderRegistration(auctionID: auctionID, phone: number)
            }
            // Due to AlamoFire restrictions we can't stop HTTP redirects
            // so to figure out if we got 302'd we have to introspect the
            // error to see if it's the original URL to know if the
            // request succeeded.
            let isError302Redirect = { (error: Error) -> Bool in
                guard case .statusCode(let response)? = error as? MoyaError else {
                    return false
                }
                guard let responseURL = response.response?.url?.absoluteString, responseURL.contains("v1/bidder/") else {
                    return false
                }
                return true
            }

            // Try logging in first with unformatted number (paddle number) and then E.164 formatted number (phone
            // number) if that doesn't work. If it _is_ a phone number, store that in nav.bidDetails.authNumberType.
            return me.provider.request(endPointGenerator(.paddleNumber))
                .filter(statusCode: 400)
                .map(void)
                .catchError({ error -> Observable<()> in
                    if (isError302Redirect(error)) {
                        me.performSegue(.ConfirmyourBidBidderFound)
                        return Observable.just(())
                    } else {
                        return me.provider.request(endPointGenerator(.phoneNumber))
                            .filter(statusCode: 400)
                            .map(void)
                            .do(onError: { error in
                                guard let me = self else { return }
                                if isError302Redirect(error) {
                                    nav.bidDetails.authNumberType = .phoneNumber
                                    me.performSegue(.ConfirmyourBidBidderFound)
                                } else {
                                    me.performSegue(.ConfirmyourBidBidderNotFound)
                                }
                            })
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
}

private extension ConfirmYourBidViewController {


    @IBAction func dev_noPhoneNumberFoundTapped(_ sender: AnyObject) {
        self.performSegue(.ConfirmyourBidArtsyLogin )
    }

    @IBAction func dev_phoneNumberFoundTapped(_ sender: AnyObject) {
        self.performSegue(.ConfirmyourBidBidderFound)
    }

}
