import UIKit
import Artsy_UILabels
import RxSwift
import Keys
import Stripe

class SwipeCreditCardViewController: UIViewController, RegistrationSubController {

    @IBOutlet var cardStatusLabel: ARSerifLabel!
    let finished = PublishSubject<Void>()

    @IBOutlet weak var titleLabel: ARSerifLabel!
    @IBOutlet weak var spinner: Spinner!
    @IBOutlet weak var illustrationImageView: UIImageView!


    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> SwipeCreditCardViewController {
        return storyboard.viewController(withID: .RegisterCreditCard) as! SwipeCreditCardViewController
    }

    let cardName = Variable("")
    let cardLastDigits = Variable("")
    let cardToken = Variable("")

    lazy var keys = EidolonKeys()
    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    lazy var appSetup = AppSetup.sharedState
    lazy var cardHandler: CardHandler = {
        if self.appSetup.useStaging {
            return CardHandler(apiKey: self.keys.cardflightStagingAPIClientKey, accountToken: self.keys.cardflightStagingMerchantAccountToken)
        } else {
            return CardHandler(apiKey: self.keys.cardflightProductionAPIClientKey, accountToken: self.keys.cardflightProductionMerchantAccountToken)
        }
    }()
    
    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInProgress(false)

        let pleaseWaitMessage = "Please wait..."

        cardHandler.userMessages
            .startWith(pleaseWaitMessage)
            .map { message in
                if message.isEmpty {
                    return pleaseWaitMessage
                } else {
                    return message
                }
            }
            .bind(to: titleLabel.rx.text)
            .disposed(by: rx.disposeBag)

        cardHandler.cardStatus
            .takeUntil(self.viewWillDisappear)
            .subscribe(onNext: { message in
                    self.cardStatusLabel.text = "Card Status: \(message)"
                    if message == "Got Card" {
                        self.setInProgress(true)
                    }
                },
                onError: { error in
                    self.cardStatusLabel.text = "Card Status: Errored"
                    self.setInProgress(false)
                    self.titleLabel.text = "Please Swipe a Valid Credit Card"
                    self.titleLabel.textColor = .artsyRedRegular()
                },
                onCompleted: {
                    self.cardStatusLabel.text = "Card Status: completed"

                    if let card = self.cardHandler.card {
                        self.cardName.value = card.cardInfo.cardholderName ?? ""
                        self.cardLastDigits.value = card.cardInfo.lastFour ?? ""

                        self.cardToken.value = card.token

                        if let newUser = self.navigationController?.fulfillmentNav().bidDetails.newUser {
                            newUser.name.value = (newUser.name.value.isNilOrEmpty) ? card.cardInfo.cardholderName : newUser.name.value
                        }
                    }
                    
                    self.cardHandler.end()
                    self.finished.onCompleted()
                },
                onDisposed: nil)
                .disposed(by: rx.disposeBag)

        cardHandler.startSearching()

        cardName
            .asObservable()
            .takeUntil(viewWillDisappear)
            .mapToOptional()
            .bind(to: bidDetails.newUser.creditCardName)
            .disposed(by: rx.disposeBag)

        cardLastDigits
            .asObservable()
            .takeUntil(viewWillDisappear)
            .mapToOptional()
            .bind(to: bidDetails.newUser.creditCardDigit)
            .disposed(by: rx.disposeBag)

        cardToken
            .asObservable()
            .takeUntil(viewWillDisappear)
            .mapToOptional()
            .bind(to: bidDetails.newUser.creditCardToken)
            .disposed(by: rx.disposeBag)

        bidDetails.newUser.swipedCreditCard = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        _viewWillDisappear.onNext(Void())
    }

    func setInProgress(_ show: Bool) {
        illustrationImageView.alpha = show ? 0.1 : 1
        spinner.isHidden = !show
    }

    // Used only for development, in private extension for testing.
    fileprivate lazy var stripeManager = StripeManager()
}

private extension SwipeCreditCardViewController {
    func applyCardWithSuccess(_ success: Bool) {
        let cardFullDigits = success ? "4242424242424242" : "4000000000000002"

        stripeManager.registerCard(digits: cardFullDigits, month: 04, year: 2018, securityCode: "123", postalCode: "10013")
            .subscribe(onNext: { [weak self] token in

                self?.cardName.value = "Kiosk Staging CC Test"
                self?.cardToken.value = token.tokenId
                self?.cardLastDigits.value = token.creditCard!.last4

                if let newUser = self?.navigationController?.fulfillmentNav().bidDetails.newUser {
                    newUser.name.value = token.creditCard?.brandName
                }

                self?.finished.onCompleted()
            })
            .disposed(by: rx.disposeBag)
    }

    @IBAction func dev_creditCardOKTapped(_ sender: AnyObject) {
        applyCardWithSuccess(true)
    }

    @IBAction func dev_creditCardFailTapped(_ sender: AnyObject) {
        applyCardWithSuccess(false)
    }
}
