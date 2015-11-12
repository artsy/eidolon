import Quick
import Nimble
import RxSwift
@testable
import Kiosk

class GenericFormValidationViewModelTests: QuickSpec {
    override func spec() {
        let validSubject = RACSignal.`return`(true).replay()

        it("executes command when manual signal sends") {
            var completed = false

            let invocationSignal = RACSubject()

            let subject = GenericFormValidationViewModel(isValidSignal: validSubject, manualInvocationSignal: invocationSignal, finishedSubject: RACSubject())

            subject.command.executing.take(1).subscribeNext { _ -> Void in
                completed = true
            }

            invocationSignal.sendNext(nil)

            expect(completed).toEventually( beTrue() )
        }

        it("sends completed on finishedSubject when command is executed") {
            var completed = false

            let invocationSignal = RACSubject()
            let finishedSubject = RACSubject()

            finishedSubject.subscribeCompleted { () -> Void in
                completed = true
            }

            let subject = GenericFormValidationViewModel(isValidSignal: validSubject, manualInvocationSignal: invocationSignal, finishedSubject: finishedSubject)

            subject.command.execute(nil)

            expect(completed).toEventually( beTrue() )
        }

        it("uses the isValidSignal for the command enabledness") {
            let validSubject = RACSubject()

            let subject = GenericFormValidationViewModel(isValidSignal: validSubject, manualInvocationSignal: RACSignal.empty(), finishedSubject: RACSubject())

            validSubject.sendNext(false)
            expect((subject.command.enabled.first() as! Bool)).toEventually( beFalse() )

            validSubject.sendNext(true)
            expect((subject.command.enabled.first() as! Bool)).toEventually( beTrue() )

            validSubject.sendNext(false)
            expect((subject.command.enabled.first() as! Bool)).toEventually( beFalse() )
        }
    }
}
