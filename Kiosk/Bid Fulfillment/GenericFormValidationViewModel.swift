import Foundation
import RxSwift
import Action

class GenericFormValidationViewModel {
    let command: CocoaAction
    let disposeBag = DisposeBag()

    init(isValidSignal: Observable<Bool>, manualInvocationSignal: Observable<Void>, finishedSubject: PublishSubject<Void>) {

        command = CocoaAction(enabledIf: isValidSignal) { _ in
            return create { observer in
                
                finishedSubject.onCompleted()
                observer.onCompleted()

                return NopDisposable.instance
            }
        }

        manualInvocationSignal
            .subscribeNext { [weak self] _ in
                self?.command.execute()
            }
            .addDisposableTo(disposeBag)
    }
}