import RxSwift

class RegistrationPostalZipViewController: UIViewController, RegistrationSubController {
    @IBOutlet var zipCodeTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finished = PublishSubject<Void>()

    lazy var viewModel: GenericFormValidationViewModel = {
        let zipCodeIsValidSignal = self.zipCodeTextField.rx_text.map(isZeroLengthString).not()
        return GenericFormValidationViewModel(isValidSignal: zipCodeIsValidSignal, manualInvocationSignal: self.zipCodeTextField.returnKeySignal(), finishedSubject: self.finished)
    }()

    private let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        zipCodeTextField.text = bidDetails.newUser.zipCode.value

        zipCodeTextField
            .rx_text
            .asObservable()
            .mapToOptional()
            .takeUntil(viewWillDisappear)
            .bindTo(bidDetails.newUser.zipCode)
            .addDisposableTo(rx_disposeBag)

        confirmButton.rx_action = viewModel.command

        zipCodeTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        _viewWillDisappear.onNext()
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> RegistrationPostalZipViewController {
        return storyboard.viewControllerWithID(.RegisterPostalorZip) as! RegistrationPostalZipViewController
    }
}
