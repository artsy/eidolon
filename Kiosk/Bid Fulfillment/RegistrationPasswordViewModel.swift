import Foundation
import RxSwift
import Moya
import Action

protocol RegistrationPasswordViewModelType {
    var emailExistsSignal: Observable<Bool> { get }
    var action: CocoaAction! { get }

    func userForgotPasswordSignal() -> Observable<Void>
}

class RegistrationPasswordViewModel: RegistrationPasswordViewModelType {

    private let password = Variable("")

    var action: CocoaAction!

    let email: String
    let emailExistsSignal: Observable<Bool>

    let disposeBag = DisposeBag()

    init(passwordSignal: Observable<String>, execute: Observable<Void>, completed: PublishSubject<Void>, email: String) {
        self.email = email

        let checkEmail = Provider
            .sharedProvider
            .request(ArtsyAPI.FindExistingEmailRegistration(email: email))
            .map(responseIsOK)
            .replay(1)

        emailExistsSignal = checkEmail

        passwordSignal.bindTo(self.password).addDisposableTo(disposeBag)

        let password = self.password

        // Action takes nothing, is enabled if the password is valid, and does the following:
        // Check if the email exists, it tries to log in.
        // If it doesn't exist, then it does nothing.
        let action = CocoaAction(enabledIf: passwordSignal.map(isStringLengthAtLeast(6))) { _ in

            return self.emailExistsSignal
                .flatMap { exists -> Observable<Void> in
                    if exists {
                        let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: email, password: password.value ?? "")
                        return Provider
                            .sharedProvider
                            .request(endpoint)
                            .filterSuccessfulStatusCodes().map(void)
                    } else {
                        // Return a non-empty observable, so that the action sends something on its elements observable.
                        return just()
                    }
                }
                .doOnCompleted {
                    completed.onCompleted()
                }
        }

        self.action = action

        // Need to trigger the API check manually.
        checkEmail.connect()

        execute
            .subscribeNext { _ in
                action.execute(Void())
            }
            .addDisposableTo(disposeBag)
    }

    func userForgotPasswordSignal() -> Observable<Void> {
        let endpoint: ArtsyAPI = ArtsyAPI.LostPasswordNotification(email: email)
        return XAppRequest(endpoint)
            .filterSuccessfulStatusCodes()
            .map(void)
            .doOnNext { (t) -> Void in
                logger.log("Sent forgot password request")
            }
    }
}
