import Quick
import Nimble
import ReactiveCocoa
import Swift_RAC_Macros
import Kiosk
import Moya

let testPassword = "password"
let testEmail = "test@example.com"

class RegistrationPasswordViewModelTests: QuickSpec {

    typealias Check = (() -> ())?
    func stubProvider(#emailExists: Bool, emailCheck: Check, loginSucceeds: Bool, loginCheck: Check, passwordRequestSucceeds: Bool, passwordCheck: Check) {
        let endpointsClosure = { (target: ArtsyAPI) -> Endpoint<ArtsyAPI> in

            switch target {
            case ArtsyAPI.FindExistingEmailRegistration(let email):
                emailCheck?()
                expect(email) == testEmail
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(emailExists ? 200 : 404, {NSData()}), method: target.method, parameters: target.parameters)
            case ArtsyAPI.LostPasswordNotification(let email):
                passwordCheck?()
                expect(email) == testEmail
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(passwordRequestSucceeds ? 200 : 404, {NSData()}), method: target.method, parameters: target.parameters)
            case ArtsyAPI.XAuth(let email, let password):
                loginCheck?()
                expect(email) == testEmail
                expect(password) == testPassword
                // Fail auth (wrong password maybe)
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(loginSucceeds ? 200 : 403, {NSData()}), method: target.method, parameters: target.parameters)
            case .XApp:
                // Any XApp requests are incidental; ignore.
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, {NSData()}), method: target.method, parameters: target.parameters)
            default:
                // Fail on all other cases
                expect(true) == false
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, {NSData()}), method: target.method, parameters: target.parameters)
            }
        }

        Provider.sharedProvider = ArtsyProvider(endpointsClosure: endpointsClosure, stubResponses: true, onlineSignal: { RACSignal.empty() })
    }

    func testSubject(passwordSubject: RACSignal = RACSignal.`return`(testPassword), invocationSignal: RACSignal = RACSubject(), finishedSubject: RACSubject = RACSubject()) -> RegistrationPasswordViewModel {
        return RegistrationPasswordViewModel(passwordSignal: passwordSubject, manualInvocationSignal: invocationSignal, finishedSubject: finishedSubject, email: testEmail)
    }

    override func spec() {

        // Just so providers form individual tests don't bleed into one another
        setupProviderForSuite(Provider.StubbingProvider())

        defaults = NSUserDefaults.standardUserDefaults()

        it("enables the command only when the password is valid") {
            let passwordSubject = RACSubject()

            let subject = self.testSubject(passwordSubject: passwordSubject)

            passwordSubject.sendNext("nope")
            expect((subject.command.enabled.first() as! Bool)).toEventually( beFalse() )

            passwordSubject.sendNext("validpassword")
            expect((subject.command.enabled.first() as! Bool)).toEventually( beTrue() )

            passwordSubject.sendNext("")
            expect((subject.command.enabled.first() as! Bool)).toEventually( beFalse() )
        }

        it("checks for an email when executing the command") {
            var checked = false

            self.stubProvider(emailExists: false, emailCheck: { () -> () in
                checked = true
            }, loginSucceeds: true, loginCheck: nil, passwordRequestSucceeds: true, passwordCheck: nil)

            let subject = self.testSubject()

            subject.command.execute(nil)

            expect(checked).toEventually( beTrue() )
        }

        it("sends true on emailExistsSignal if email exists") {
            var exists = false

            self.stubProvider(emailExists: true, emailCheck: { () -> () in
                exists = true
            }, loginSucceeds: true, loginCheck: nil, passwordRequestSucceeds: true, passwordCheck: nil)

            let subject = self.testSubject()

            subject.emailExistsSignal.subscribeNext { (object) -> Void in
                exists = object as? Bool ?? false
            }

            subject.command.execute(nil)
            
            expect(exists).toEventually( beTrue() )
        }

        it("sends false on emailExistsSignal if email does not exist") {
            var exists: Bool?

            self.stubProvider(emailExists: false, emailCheck: { () -> () in
                exists = true
            }, loginSucceeds: true, loginCheck: nil, passwordRequestSucceeds: true, passwordCheck: nil)

            let subject = self.testSubject()

            subject.emailExistsSignal.subscribeNext { (object) -> Void in
                exists = object as? Bool
            }

            subject.command.execute(nil)

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

            subject.command.execute(nil)
            
            expect(checked).toEventually( beTrue() )
            expect(authed).toEventually( beTrue() )
        }

        it("sends an error on the command if the authorization fails") {
            self.stubProvider(emailExists: true, emailCheck: nil, loginSucceeds: false, loginCheck: nil, passwordRequestSucceeds: true, passwordCheck: nil)

            let subject = self.testSubject()

            var errored = false

            subject.command.errors.subscribeNext { _ -> Void in
                errored = true
            }

            subject.command.execute(nil)

            expect(errored).toEventually( beTrue() )
        }

        it("executes command when manual signal sends") {
            self.stubProvider(emailExists: false, emailCheck: nil, loginSucceeds: false, loginCheck: nil, passwordRequestSucceeds: true, passwordCheck: nil)

            let invocationSignal = RACSubject()

            let subject = self.testSubject(invocationSignal: invocationSignal)

            var completed = false

            subject.command.executing.take(1).subscribeNext { _ -> Void in
                completed = true
            }

            invocationSignal.sendNext(nil)
            
            expect(completed).toEventually( beTrue() )
        }

        it("sends completed on finishedSubject when command is executed") {
            let invocationSignal = RACSubject()
            let finishedSubject = RACSubject()

            var completed = false

            finishedSubject.subscribeCompleted { () -> Void in
                completed = true
            }

            let subject = self.testSubject(invocationSignal:invocationSignal, finishedSubject: finishedSubject)

            subject.command.execute(nil)

            expect(completed).toEventually( beTrue() )
        }

        it("handles password reminders") {
            var sent = false

            self.stubProvider(emailExists: false, emailCheck: nil, loginSucceeds: false, loginCheck: nil, passwordRequestSucceeds: true, passwordCheck: {
                sent = true
            })

            let subject = self.testSubject()

            subject.userForgotPasswordSignal().subscribeNext { _ -> Void in
                // do nothing – we subscribe just to force the signal to execute.
            }
            
            expect(sent).toEventually( beTrue() )
            Provider.sharedProvider = Provider.StubbingProvider()
        }
    }
}
