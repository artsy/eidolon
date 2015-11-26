import UIKit
import RxSwift

class RegistrationEmailViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {

    @IBOutlet var emailTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    var finished = PublishSubject<Void>()

    lazy var viewModel: GenericFormValidationViewModel = {
        let emailIsValidSignal = self.emailTextField.rx_text.map(stringIsEmailAddress)
        return GenericFormValidationViewModel(isValidSignal: emailIsValidSignal, manualInvocationSignal: self.emailTextField.returnKeySignal(), finishedSubject: self.finished)
    }()


    private let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.text = bidDetails.newUser.email.value
        emailTextField.rx_text
            .asObservable()
            .mapToOptional()
            .takeUntil(viewWillDisappear)
            .bindTo(bidDetails.newUser.email)
            .addDisposableTo(rx_disposeBag)

        confirmButton.rx_action = viewModel.command

        emailTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        _viewWillDisappear.onNext()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if (string.isEmpty) { return true }

        // the API doesn't accept spaces
        return string != " "
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> RegistrationEmailViewController {
        return storyboard.viewControllerWithID(.RegisterEmail) as! RegistrationEmailViewController
    }
}
