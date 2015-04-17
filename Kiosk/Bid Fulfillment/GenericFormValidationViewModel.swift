import Foundation
import ReactiveCocoa

public class GenericFormValidationViewModel {
    public let command: RACCommand

    public init (isValidSignal: RACSignal, manualInvocationSignal: RACSignal, finishedSubject: RACSubject) {
        command = RACCommand(enabled: isValidSignal) { _ -> RACSignal! in
            return RACSignal.createSignal { (subscriber) -> RACDisposable! in
                finishedSubject.sendCompleted()
                subscriber.sendCompleted()

                return nil
            }
        }

        manualInvocationSignal.subscribeNext { [weak self] _ -> Void in
            self?.command.execute(nil)
            return
        }
    }
}