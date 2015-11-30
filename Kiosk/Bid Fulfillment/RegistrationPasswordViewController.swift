import UIKit
import RxSwift
import Moya
import Action

class RegistrationPasswordViewController: UIViewController, RegistrationSubController {
    @IBOutlet var passwordTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var forgotPasswordButton: UIButton!
    let finished = PublishSubject<Void>()

    private let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    lazy var viewModel: RegistrationPasswordViewModel = {
        let email = self.navigationController?.fulfillmentNav().bidDetails.newUser.email.value ?? ""

        return RegistrationPasswordViewModel(
            passwordSignal: self.passwordTextField.rx_text.asObservable(),
            execute: self.passwordTextField.rx_returnKey,
            completed: self.finished,
            email: email)
    }()

    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        forgotPasswordButton.hidden = false

        let passwordTextSignal = passwordTextField.rx_text
        passwordTextSignal
            .asObservable()
            .mapToOptional()
            .takeUntil(viewWillDisappear)
            .bindTo(bidDetails.newUser.password)
            .addDisposableTo(rx_disposeBag)

        confirmButton.rx_action = viewModel.action

        viewModel
            .action
            .errors
            .subscribeNext { [weak self] _ -> Void in
                self?.showAuthenticationError()
                return
            }
            .addDisposableTo(rx_disposeBag)


        viewModel
            .emailExistsSignal
            .not()
            .startWith(true)
            .bindTo(forgotPasswordButton.rx_hidden)
            .addDisposableTo(rx_disposeBag)


        forgotPasswordButton.rx_action = CocoaAction { [weak self] _ in
            return self?
                .viewModel
                .userForgotPasswordSignal()
                .then {
                    self?.alertUserPasswordSent()
                } ?? empty()
        }

        viewModel
            .emailExistsSignal
            .map { emailExists in
                if emailExists {
                    return "Enter your Artsy password"
                } else {
                    return "Create a password"
                }
            }
            .bindTo(subtitleLabel.rx_text)
            .addDisposableTo(rx_disposeBag)

        passwordTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        _viewWillDisappear.onNext()
    }

    func alertUserPasswordSent() -> Observable<Void> {
        return create { observer in

            let alertController = UIAlertController(title: "Forgot Password", message: "We have sent you your password.", preferredStyle: .Alert)

            let okAction = UIAlertAction(title: "OK", style: .Default) { (_) in }

            alertController.addAction(okAction)

            self.presentViewController(alertController, animated: true) {
                observer.onCompleted()
            }

            return NopDisposable.instance
        }
    }
    
    func showAuthenticationError() {
        confirmButton.flashError("Incorrect")
        passwordTextField.flashForError()
        confirmButton.setEnabled(false, animated: false)
        navigationController!.fulfillmentNav().bidDetails.newUser.password.value = ""
        passwordTextField.text = ""
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> RegistrationPasswordViewController {
        return storyboard.viewControllerWithID(.RegisterPassword) as! RegistrationPasswordViewController
    }
}
