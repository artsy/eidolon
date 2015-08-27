import Foundation
import ReactiveCocoa
import Swift_RAC_Macros

let KeypadViewModelMaxIntegerValue = 1_000_000

class KeypadViewModel: NSObject {
    
    dynamic private var intValue: Int = 0
    dynamic private var stringValue: String = ""
    
    //MARK: - Signals
    
    lazy var intValueSignal: RACSignal = {
        RACObserve(self, "intValue")
    }()
    
    lazy var stringValueSignal: RACSignal = {
        RACObserve(self, "stringValue")
    }()
    
    // MARK: - Commands
    
    // I have no idea why, but if you try and use `[weak self]` in the closure definition of a RACCommand, the compiler segfaults ¯\_(ツ)_/¯
    
    lazy var deleteCommand: RACCommand = {
        let localSelf = self
        return RACCommand { [weak localSelf] _ -> RACSignal! in
            localSelf?.deleteSignal() ?? RACSignal.empty()
        }
    }()

    lazy var clearCommand: RACCommand = {
        let localSelf = self
        return RACCommand { [weak localSelf] _ -> RACSignal! in
            localSelf?.clearSignal() ?? RACSignal.empty()
        }
    }()
    
    lazy var addDigitCommand: RACCommand = {
        let localSelf = self
        return RACCommand { [weak localSelf] (input) -> RACSignal! in
            return localSelf?.addDigitSignal(input as! Int) ?? RACSignal.empty()
        }
    }()
}

private extension KeypadViewModel {
    func deleteSignal() -> RACSignal {
        return RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            if let strongSelf = self {
                strongSelf.intValue = Int(strongSelf.intValue/10)
                if strongSelf.stringValue.isNotEmpty {
                    let string = strongSelf.stringValue
                    strongSelf.stringValue = string.substringToIndex(string.endIndex.predecessor())
                }
            }
            subscriber.sendCompleted()
            return nil
        }
    }
    
    func clearSignal() -> RACSignal {
        return  RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            self?.intValue = 0
            self?.stringValue = ""
            subscriber.sendCompleted()
            return nil
        }
    }
    
    func addDigitSignal(input: Int) -> RACSignal {
        return RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            if let strongSelf = self {
                let newValue = (10 * (strongSelf.intValue ?? 0)) + input
                if (newValue < KeypadViewModelMaxIntegerValue) {
                    strongSelf.intValue = newValue
                }
                strongSelf.stringValue = "\(strongSelf.stringValue)\(input)"
            }
            subscriber.sendCompleted()
            return nil
        }
    }
}
