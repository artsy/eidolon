import Quick
import Nimble
import RxSwift
@testable
import Kiosk

class GenericFormValidationViewModelTests: QuickSpec {
    override func spec() {
        var validSubject: Observable<Bool>!
        var disposeBag: DisposeBag!

        beforeEach {
            validSubject = just(true)
            disposeBag = DisposeBag()
        }

        it("executes command when manual signal sends") {
            var completed = false

            let invocationSignal = PublishSubject<Void>()

            let subject = GenericFormValidationViewModel(isValidSignal: validSubject, manualInvocationSignal: invocationSignal, finishedSubject: PublishSubject<Void>())

            subject.command.executing.take(1).subscribeNext { _ in
                completed = true
            }.addDisposableTo(disposeBag)

            invocationSignal.onNext()

            expect(completed).toEventually( beTrue() )
        }

        it("sends completed on finishedSubject when command is executed") {
            var completed = false

            let invocationSignal = PublishSubject<Void>()
            let finishedSubject = PublishSubject<Void>()

            finishedSubject.subscribeCompleted {
                completed = true
            }.addDisposableTo(disposeBag)

            let subject = GenericFormValidationViewModel(isValidSignal: validSubject, manualInvocationSignal: invocationSignal, finishedSubject: finishedSubject)

            subject.command.execute()

            expect(completed).toEventually( beTrue() )
        }

        it("uses the isValidSignal for the command enabledness") {
            let validSubject = PublishSubject<Bool>()

            let subject = GenericFormValidationViewModel(isValidSignal: validSubject, manualInvocationSignal: empty(), finishedSubject: PublishSubject<Void>())

            validSubject.onNext(false)
            expect(subject.command.enabled).toEventually( equalFirst(false) )

            validSubject.onNext(true)
            expect(subject.command.enabled).toEventually( equalFirst(true) )

            validSubject.onNext(false)
            expect(subject.command.enabled).toEventually( equalFirst(false) )
        }
    }
}
