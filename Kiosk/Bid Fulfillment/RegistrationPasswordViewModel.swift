import Foundation
import RxSwift
import Moya
import Action

class RegistrationPasswordViewModel {
    private let password = BehaviorSubject(value: "")

    let action: Action<Void, AnyObject>

    let email: String

    let disposeBag = DisposeBag()
    
    init(passwordSignal: Observable<String>, execute: Observable<Void>, completed: AnyObserver<Void>, email: String) {
        self.email = email

        let endpoint: ArtsyAPI = ArtsyAPI.FindExistingEmailRegistration(email: email)
        let emailExistsSignal = Provider.sharedProvider.request(endpoint).map(responseIsOK).replay(1)

        passwordSignal.bindTo(self.password).addDisposableTo(disposeBag)

        let password = self.password

        let action: Action<Void, AnyObject> = Action(enabledIf: passwordSignal.map(isStringLengthAtLeast(6)), workFactory: { (_) -> Observable<AnyObject> in
            return emailExistsSignal.map { exists -> Observable<AnyObject> in
                if exists {
                    let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: email, password: password.value ?? "")
                    return Provider.sharedProvider.request(endpoint).filterSuccessfulStatusCodes().mapJSON()
                } else {
                    return empty()
                }
                }.switchLatest().doOnCompleted {
                    completed.onCompleted()
            }
        })

        self.action = action

        execute.subscribeNext { _ in
            action.execute(Void())
        }.addDisposableTo(disposeBag)

    }

    func userForgotPasswordSignal() -> Observable<Void> {
        let endpoint: ArtsyAPI = ArtsyAPI.LostPasswordNotification(email: email)
        return XAppRequest(endpoint).filterSuccessfulStatusCodes().map(void).doOnNext { (t) -> Void in
            logger.log("Sent forgot password request")
        }
    }
}
