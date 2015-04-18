import Foundation
import ReactiveCocoa
import Moya
import Swift_RAC_Macros

public class RegistrationPasswordViewModel {
    private class PasswordHolder: NSObject {
        dynamic var password: String = ""
    }

    public var emailExistsSignal: RACSignal
    public let command: RACCommand
    let email: String
    
    public init(passwordSignal: RACSignal, manualInvocationSignal: RACSignal, finishedSubject: RACSubject, email: String) {
        let endpoint: ArtsyAPI = ArtsyAPI.FindExistingEmailRegistration(email: email)
        let emailExistsSignal = Provider.sharedProvider.request(endpoint, method: .GET, parameters:endpoint.defaultParameters).map(responseIsOK).replayLast()

        let passwordHolder = PasswordHolder()
        RAC(passwordHolder, "password") <~ passwordSignal

        command = RACCommand(enabled: passwordSignal.map(minimum6CharString)) { _ -> RACSignal! in
            return emailExistsSignal.map { (object) -> AnyObject! in
                let emailExists = object as Bool

                if emailExists {
                    let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: email, password: passwordHolder.password)
                    return Provider.sharedProvider.request(endpoint, method:.GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON()
                } else {
                    return RACSignal.empty()
                }
            }.switchToLatest().doCompleted { () -> Void in
                finishedSubject.sendCompleted()
            }
        }

        self.emailExistsSignal = emailExistsSignal
        self.email = email

        manualInvocationSignal.subscribeNext { [weak self] _ -> Void in
            self?.command.execute(nil)
            return
        }
    }

    public func userForgotPasswordSignal() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.LostPasswordNotification(email: email)
        return XAppRequest(endpoint, method: .POST, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().doNext { (json) -> Void in
            logger.log("Sent forgot password request")
        }
    }
}