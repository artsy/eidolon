import Foundation
import ReactiveCocoa
import Swift_RAC_Macros

let KeypadViewModelMaxValue = 1_000_000

public class KeypadViewModel: NSObject {
    
    dynamic private var value: Int = 0
    
    lazy var valueSignal: RACSignal = {
        RACObserve(self, "value")
    }()
    
    lazy var valueIsZeroSignal: RACSignal = {
        self.valueSignal.map { return ($0 as Int == 0) }
    }()
    
    lazy var deleteCommand: RACCommand = {
        RACCommand(enabled: self.valueIsZeroSignal.not()) { [weak self] (_) -> RACSignal! in
            self?.deleteSignal() ?? RACSignal.empty()
        }
    }()

    lazy var clearCommand: RACCommand = {
        RACCommand(enabled: self.valueIsZeroSignal.not()) { [weak self] (_) -> RACSignal! in
            self?.clearSignal() ?? RACSignal.empty()
        }
    }()
    
    lazy var addDigitCommand: RACCommand = {
        // I have no idea why, but if you try and use `[weak self]` in the closure definition, the compiler segfaults ¯\_(ツ)_/¯
        let localSelf = self
        return RACCommand { [weak localSelf] (input) -> RACSignal! in
            localSelf?.addDigitSignal(input as Int) ?? RACSignal.empty()
        }
    }()
}

public extension RACSignal {
    func mapIntToString() -> RACSignal {
        return map { (input) -> AnyObject! in
            return String(input as Int)
        }
    }
}

private extension KeypadViewModel {
    func deleteSignal() -> RACSignal {
        return RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            if let strongSelf = self {
                strongSelf.value = Int(strongSelf.value/10)
            }
            subscriber.sendCompleted()
            return nil
        }
    }
    
    func clearSignal() -> RACSignal {
        return  RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            self?.value = 0
            subscriber.sendCompleted()
            return nil
        }
    }
    
    func addDigitSignal(input: Int) -> RACSignal {
        return RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            if let strongSelf = self {
                let newValue = (10 * (self?.value ?? 0)) + input
                if (newValue < KeypadViewModelMaxValue) {
                    strongSelf.value = newValue
                }
            }
            subscriber.sendCompleted()
            return nil
        }
    }
}
