import Foundation
import RxSwift
import Action

class GenericFormValidationViewModel {
    let command: CocoaAction
    let disposeBag = DisposeBag()

    init(isValid: Observable<Bool>, manualInvocation: Observable<Void>, finishedSubject: PublishSubject<Void>) {

        command = CocoaAction(enabledIf: isValid) { _ in
            return create { observer in
                
                finishedSubject.onCompleted()
                observer.onCompleted()

                return NopDisposable.instance
            }
        }

        manualInvocation
            .subscribeNext { [weak self] _ in
                self?.command.execute()
            }
            .addDisposableTo(disposeBag)
    }
}