import Foundation
import Action
import RxSwift

let KeypadViewModelMaxIntegerValue = 10_000_000

class KeypadViewModel: NSObject {
    
    //MARK: - Variables
    
    lazy var intValue = Variable(0)
    
    lazy var stringValue = Variable("")
    
    // MARK: - Actions

    
    lazy var deleteAction: CocoaAction = {
        return CocoaAction { [weak self] _ in
            self?.deleteSignal() ?? empty()
        }
    }()

    lazy var clearAction: CocoaAction = {
        return CocoaAction { [weak self] _ in
            self?.clearSignal() ?? empty()
        }
    }()
    
    lazy var addDigitAction: Action<Int, Void> = {
        let localSelf = self
        return Action<Int, Void> { [weak localSelf] input in
            return localSelf?.addDigitSignal(input) ?? empty()
        }
    }()
}

private extension KeypadViewModel {
    func deleteSignal() -> Observable<Void> {
        return create { [weak self] observer in
            if let strongSelf = self {
                strongSelf.intValue.value = Int(strongSelf.intValue.value / 10)
                if strongSelf.stringValue.value.isNotEmpty {
                    let string = strongSelf.stringValue.value
                    strongSelf.stringValue.value = string.substringToIndex(string.endIndex.predecessor())
                }
            }
            observer.onCompleted()
            return NopDisposable.instance
        }
    }
    
    func clearSignal() -> Observable<Void> {
        return create { [weak self] observer in
            self?.intValue.value = 0
            self?.stringValue.value = ""
            observer.onCompleted()
            return NopDisposable.instance
        }
    }
    
    func addDigitSignal(input: Int) -> Observable<Void> {
        return create { [weak self] observer in
            if let strongSelf = self {
                let newValue = (10 * strongSelf.intValue.value) + input
                if (newValue < KeypadViewModelMaxIntegerValue) {
                    strongSelf.intValue.value = newValue
                }
                strongSelf.stringValue.value = "\(strongSelf.stringValue.value)\(input)"
            }
            observer.onCompleted()
            return NopDisposable.instance
        }
    }
}
