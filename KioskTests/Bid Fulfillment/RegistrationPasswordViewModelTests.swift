import Quick
import Nimble
import RxSwift
@testable
import Kiosk
import Moya
import RxBlocking

let testPassword = "password"
let testEmail = "test@example.com"

class RegistrationPasswordViewModelTests: QuickSpec {

    typealias Check = (() -> ())?
    func stubProvider(emailExists emailExists: Bool, emailCheck: Check, loginSucceeds: Bool, loginCheck: Check, passwordRequestSucceeds: Bool, passwordCheck: Check) {
        let endpointsClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in

            switch target {
            case ArtsyAPI.FindExistingEmailRegistration(let email):
                emailCheck?()
                expect(email) == testEmail
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponseClosure: {.NetworkResponse(emailExists ? 200 : 404, NSData())}, method: target.method, parameters: target.parameters)
            case ArtsyAPI.LostPasswordNotification(let email):
                passwordCheck?()
                expect(email) == testEmail
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponseClosure: {.NetworkResponse(passwordRequestSucceeds ? 200 : 404, NSData())}, method: target.method, parameters: target.parameters)
            case ArtsyAPI.XAuth(let email, let password):
                loginCheck?()
                expect(email) == testEmail
                expect(password) == testPassword
                // Fail auth (wrong password maybe)
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponseClosure: {.NetworkResponse(loginSucceeds ? 200 : 403, NSData())}, method: target.method, parameters: target.parameters)
            case .XApp:
                // Any XApp requests are incidental; ignore.
                return MoyaProvider<ArtsyAPI>.DefaultEndpointMapping(target)
            default:
                // Fail on all other cases
                fail("Unexpected network call")
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponseClosure: {.NetworkResponse(200, NSData())}, method: target.method, parameters: target.parameters)
            }
        }

        Provider.sharedProvider = ArtsyProvider(endpointClosure: endpointsClosure, stubClosure: MoyaProvider.ImmediatelyStub, online: just(true))
    }

    func testSubject(passwordSubject: Observable<String> = just(testPassword), invocation: Observable<Void> = PublishSubject<Void>().asObservable(), finishedSubject: PublishSubject<Void> = PublishSubject<Void>()) -> RegistrationPasswordViewModel {
        return RegistrationPasswordViewModel(password: passwordSubject, execute: invocation, completed: finishedSubject, email: testEmail)
    }

    override func spec() {

        // Just so providers form individual tests don't bleed into one another
        setupProviderForSuite(Provider.StubbingProvider())

        defaults = NSUserDefaults.standardUserDefaults()

        var disposeBag: DisposeBag!

        beforeEach {
            disposeBag = DisposeBag()
        }

        afterEach {
            Provider.sharedProvider = Provider.StubbingProvider()
        }

        it("enables the command only when the password is valid") {
            let passwordSubject = PublishSubject<String>()

            let subject = self.testSubject(passwordSubject.asObservable())

            passwordSubject.onNext("nope")
            expect(try! subject.action.enabled.toBlocking().first()).toEventually( beFalse() )

            passwordSubject.onNext("validpassword")
            expect(try! subject.action.enabled.toBlocking().first()).toEventually( beTrue() )

            passwordSubject.onNext("")
            expect(try! subject.action.enabled.toBlocking().first()).toEventually( beFalse() )
        }

        it("checks for an email when executing the command") {
            var checked = false

            self.stubProvider(emailExists: false, emailCheck: {
                checked = true
            }, loginSucceeds: true, loginCheck: nil, passwordRequestSucceeds: true, passwordCheck: nil)

            let subject = self.testSubject()

            subject.action.execute()

            expect(checked).toEventually( beTrue() )
        }

        it("sends true on emailExists if email exists") {
            var exists = false

            self.stubProvider(emailExists: true, emailCheck: {
                exists = true
            }, loginSucceeds: true, loginCheck: nil, passwordRequestSucceeds: true, passwordCheck: nil)

            let subject = self.testSubject()

            subject
                .emailExists
                .subscribeNext { (object) in
                    exists = object
                }
                .addDisposableTo(disposeBag)

            subject.action.execute()
            
            expect(exists).toEventually( beTrue() )
        }

        it("sends false on emailExists if email does not exist") {
            var exists: Bool?

            self.stubProvider(emailExists: false, emailCheck: {
                exists = true
            }, loginSucceeds: true, loginCheck: nil, passwordRequestSucceeds: true, passwordCheck: nil)

            let subject = self.testSubject()

            subject
                .emailExists
                .subscribeNext { (object) in
                    exists = object
                }
                .addDisposableTo(disposeBag)

            subject.action.execute()

            expect(exists).toEventuallyNot( beNil() )
            expect(exists).toEventually( beFalse() )
        }

        it("checks for authorization if the email exists") {
            var checked = false
            var authed = false

            self.stubProvider(emailExists: true, emailCheck: {
                checked = true
            }, loginSucceeds: true, loginCheck: {
                authed = true
            }, passwordRequestSucceeds: true, passwordCheck: nil)

            let subject = self.testSubject()

            subject.action.execute()
            
            expect(checked).toEventually( beTrue() )
            expect(authed).toEventually( beTrue() )
        }

        it("sends an error on the command if the authorization fails") {
            self.stubProvider(emailExists: true, emailCheck: nil, loginSucceeds: false, loginCheck: nil, passwordRequestSucceeds: true, passwordCheck: nil)

            let subject = self.testSubject()

            var errored = false

            subject
                .action
                .errors
                .subscribeNext { _ in
                    errored = true
                }
                .addDisposableTo(disposeBag)

            subject.action.execute()

            expect(errored).toEventually( beTrue() )
        }

        it("executes command when manual  sends") {
            self.stubProvider(emailExists: false, emailCheck: nil, loginSucceeds: false, loginCheck: nil, passwordRequestSucceeds: true, passwordCheck: nil)

            let invocation = PublishSubject<Void>()

            let subject = self.testSubject(invocation: invocation)

            var completed = false

            subject
                .action
                .executing
                .take(1)
                .subscribeNext { _ in
                    completed = true
                }
                .addDisposableTo(disposeBag)

            invocation.onNext()
            
            expect(completed).toEventually( beTrue() )
        }

        it("sends completed on finishedSubject when command is executed") {
            let invocation = PublishSubject<Void>()
            let finishedSubject = PublishSubject<Void>()

            var completed = false

            finishedSubject
                .subscribeCompleted {
                    completed = true
                }
                .addDisposableTo(disposeBag)

            let subject = self.testSubject(invocation:invocation, finishedSubject: finishedSubject)

            subject.action.execute()

            expect(completed).toEventually( beTrue() )
        }

        it("handles password reminders") {
            var sent = false

            self.stubProvider(emailExists: true, emailCheck: nil, loginSucceeds: true, loginCheck: nil, passwordRequestSucceeds: true, passwordCheck: {
                sent = true
            })

            let subject = self.testSubject()

            waitUntil { done in
                subject
                    .userForgotPassword()
                    .subscribeCompleted {
                        // do nothing – we subscribe just to force the  to execute.
                        done()
                    }
                    .addDisposableTo(disposeBag)
            }

            expect(sent).toEventually( beTrue() )
            Provider.sharedProvider = Provider.StubbingProvider()
        }
    }
}
