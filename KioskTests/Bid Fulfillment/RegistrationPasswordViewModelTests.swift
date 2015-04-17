import Quick
import Nimble
import ReactiveCocoa
import Swift_RAC_Macros
import Kiosk
import Moya

class RegistrationPasswordViewModelTests: QuickSpec {
    override func spec() {
        let testPassword = "password"
        let testEmail = "test@example.com"

        // Just so providers form individual tests don't bleed into one another
        setupProviderForSuite(Provider.StubbingProvider())

        defaults = NSUserDefaults.standardUserDefaults()

        it("enables the command only when the password is valid") {
            let passwordSubject = RACSubject()

            let subject = RegistrationPasswordViewModel(passwordSignal: passwordSubject,
                manualInvocationSignal: RACSignal.empty(),
                finishedSubject: RACSubject(),
                email: testEmail)


            passwordSubject.sendNext("nope")
            expect((subject.command.enabled.first() as Bool)).toEventually( beFalse() )

            passwordSubject.sendNext("validpassword")
            expect((subject.command.enabled.first() as Bool)).toEventually( beTrue() )

            passwordSubject.sendNext("")
            expect((subject.command.enabled.first() as Bool)).toEventually( beFalse() )
        }

        it("checks for an email when executing the command") {
            var checked = false

            let endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in

                switch target {
                case ArtsyAPI.FindExistingEmailRegistration(let email):
                    checked = true
                    expect(email) == testEmail
                default:
                    // Fail on all other cases
                    expect(true) == false
                }

                // The email doesn't exist
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(404, NSData()), method: method, parameters: parameters)
            }

            Provider.sharedProvider = ArtsyProvider(endpointsClosure: endpointsClosure, stubResponses: true, onlineSignal: { RACSignal.empty() })

            let subject = RegistrationPasswordViewModel(passwordSignal: RACSignal.`return`(testPassword),
                manualInvocationSignal: RACSignal.empty(),
                finishedSubject: RACSubject(),
                email: testEmail)

            subject.command.execute(nil)

            expect(checked).toEventually( beTrue() )
        }

        it("sends true on emailExistsSignal if email exists") {
            var exists = false

            let endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in

                // Everything is 👌, so return 200 and empty data
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, NSData()), method: method, parameters: parameters)
            }

            Provider.sharedProvider = ArtsyProvider(endpointsClosure: endpointsClosure, stubResponses: true, onlineSignal: { RACSignal.empty() })

            let subject = RegistrationPasswordViewModel(passwordSignal: RACSignal.`return`(testPassword),
                manualInvocationSignal: RACSignal.empty(),
                finishedSubject: RACSubject(),
                email: testEmail)

            subject.emailExistsSignal.subscribeNext { (object) -> Void in
                exists = object as? Bool ?? false
            }

            subject.command.execute(nil)
            
            expect(exists).toEventually( beTrue() )
        }

        it("sends false on emailExistsSignal if email does not exist") {
            var exists: Bool?

            let endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in

                // Email doesn't exist, so return 404 and empty data
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(404, NSData()), method: method, parameters: parameters)
            }

            Provider.sharedProvider = ArtsyProvider(endpointsClosure: endpointsClosure, stubResponses: true, onlineSignal: { RACSignal.empty() })

            let subject = RegistrationPasswordViewModel(passwordSignal: RACSignal.`return`(testPassword),
                manualInvocationSignal: RACSignal.empty(),
                finishedSubject: RACSubject(),
                email: testEmail)

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

            let endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in

                switch target {
                case ArtsyAPI.FindExistingEmailRegistration(let email):
                    checked = true
                    expect(email) == testEmail
                    // The email exists
                    return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, NSData()), method: method, parameters: parameters)
                case ArtsyAPI.XAuth(let email, let password):
                    authed = true
                    expect(email) == testEmail
                    expect(password) == testPassword

                    return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, NSData()), method: method, parameters: parameters)
                default:
                    // Fail on all other cases
                    expect(true) == false
                }

                // Silences compiler error
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, NSData()), method: method, parameters: parameters)
            }

            Provider.sharedProvider = ArtsyProvider(endpointsClosure: endpointsClosure, stubResponses: true, onlineSignal: { RACSignal.empty() })

            let subject = RegistrationPasswordViewModel(passwordSignal: RACSignal.`return`(testPassword),
                manualInvocationSignal: RACSignal.empty(),
                finishedSubject: RACSubject(),
                email: testEmail)

            subject.command.execute(nil)
            
            expect(checked).toEventually( beTrue() )
            expect(authed).toEventually( beTrue() )
        }

        it("sends an error on the command if the authorization fails") {
            let endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in

                switch target {
                case ArtsyAPI.FindExistingEmailRegistration(let email):
                    // The email exists
                    return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, NSData()), method: method, parameters: parameters)
                case ArtsyAPI.XAuth(let email, let password):
                    // Fail auth (wrong password maybe)
                    return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(403, NSData()), method: method, parameters: parameters)
                default:
                    // Fail on all other cases
                    expect(true) == false
                }

                // Silences compiler error
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, NSData()), method: method, parameters: parameters)
            }

            Provider.sharedProvider = ArtsyProvider(endpointsClosure: endpointsClosure, stubResponses: true, onlineSignal: { RACSignal.empty() })

            let subject = RegistrationPasswordViewModel(passwordSignal: RACSignal.`return`(testPassword),
                manualInvocationSignal: RACSignal.empty(),
                finishedSubject: RACSubject(),
                email: testEmail)

            var errored = false

            subject.command.errors.subscribeNext { _ -> Void in
                errored = true
            }

            subject.command.execute(nil)

            expect(errored).toEventually( beTrue() )
        }

        it("executes command when manual signal sends") {
            let endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in

                switch target {
                case ArtsyAPI.FindExistingEmailRegistration(let email):
                    // The email doesn't exist
                    return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(404, NSData()), method: method, parameters: parameters)
                default:
                    return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, NSData()), method: method, parameters: parameters)
                }
            }

            Provider.sharedProvider = ArtsyProvider(endpointsClosure: endpointsClosure, stubResponses: true, onlineSignal: { RACSignal.empty() })

            let invocationSignal = RACSubject()

            let subject = RegistrationPasswordViewModel(passwordSignal: RACSignal.`return`(testPassword),
                manualInvocationSignal: invocationSignal,
                finishedSubject: RACSubject(),
                email: testEmail)

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

            let subject = RegistrationPasswordViewModel(passwordSignal: RACSignal.`return`(testPassword),
                manualInvocationSignal: invocationSignal,
                finishedSubject: finishedSubject,
                email: testEmail)

            subject.command.execute(nil)

            expect(completed).toEventually( beTrue() )
        }

        it("handles password reminders") {
            var sent = false

            let endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in

                // Swift needs at least one executable statement per case  ¯\_(ツ)_/¯
                var a = 0
                switch target {
                case ArtsyAPI.FindExistingEmailRegistration:
                    // Ignore; the subject tests this upon initialization
                    a = 0
                case ArtsyAPI.LostPasswordNotification(let email):
                    sent = true
                    expect(email) == testEmail
                case .XApp:
                    a = 0
                default:
                    // Fail on all other cases
                    expect(true) == false
                }

                // We're A-OK
                return Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, NSData()), method: method, parameters: parameters)
            }

            Provider.sharedProvider = ArtsyProvider(endpointsClosure: endpointsClosure, stubResponses: true, onlineSignal: { RACSignal.empty() })

            let subject = RegistrationPasswordViewModel(passwordSignal: RACSignal.`return`(testPassword),
                manualInvocationSignal: RACSignal.empty(),
                finishedSubject: RACSubject(),
                email: testEmail)

            subject.userForgotPasswordSignal().subscribeNext { _ -> Void in
                // do nothing – we subscribe just to force the signal to execute.
            }
            
            expect(sent).toEventually( beTrue() )
            Provider.sharedProvider = Provider.StubbingProvider()
        }
    }
}
