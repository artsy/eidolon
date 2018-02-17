import Quick
import Nimble
import RxNimble
import RxSwift
@testable
import Kiosk

class GenericFormValidationViewModelTests: QuickSpec {
    override func spec() {
        var validSubject: Observable<Bool>!
        var disposeBag: DisposeBag!

        beforeEach {
            validSubject = Observable.just(true)
            disposeBag = DisposeBag()
        }

        it("executes command when manual  sends") {
            var completed = false

            let invocation = PublishSubject<Void>()

            let subject = GenericFormValidationViewModel(isValid: validSubject, manualInvocation: invocation, finishedSubject: PublishSubject<Void>())

            subject.command.executing.take(1).subscribe(onNext: { _ in
                completed = true
            }).disposed(by: disposeBag)

            invocation.onNext(Void())

            expect(completed).toEventually( beTrue() )
        }

        it("sends completed on finishedSubject when command is executed") {
            var completed = false

            let invocation = PublishSubject<Void>()
            let finishedSubject = PublishSubject<Void>()

            finishedSubject.subscribe(onCompleted: {
                completed = true
            }).disposed(by: disposeBag)

            let subject = GenericFormValidationViewModel(isValid: validSubject, manualInvocation: invocation, finishedSubject: finishedSubject)

            subject.command.execute(Void())

            expect(completed).toEventually( beTrue() )
        }

        it("uses the isValid for the command enabledness") {
            let validSubject = PublishSubject<Bool>()

            let subject = GenericFormValidationViewModel(isValid: validSubject, manualInvocation: Observable.empty(), finishedSubject: PublishSubject<Void>())

            validSubject.onNext(false)
            expect(subject.command.enabled).first.toEventually( equal(false) )

            validSubject.onNext(true)
            expect(subject.command.enabled).first.toEventually( equal(true) )

            validSubject.onNext(false)
            expect(subject.command.enabled).first.toEventually( equal(false) )
        }
    }
}
