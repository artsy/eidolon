import Foundation
import Action
import RxSwift

let KeypadViewModelMaxIntegerValue: Currency = 10_000_000

class KeypadViewModel: NSObject {
    
    //MARK: - Variables
    
    lazy var currencyValue = Variable<Currency>(0)
    
    lazy var stringValue = Variable("")
    
    // MARK: - Actions

    
    lazy var deleteAction: CocoaAction = {
        return CocoaAction { [weak self] _ in
            self?.delete() ?? .empty()
        }
    }()

    lazy var clearAction: CocoaAction = {
        return CocoaAction { [weak self] _ in
            self?.clear() ?? .empty()
        }
    }()
    
    lazy var addDigitAction: Action<Int, Void> = {
        let localSelf = self
        return Action<Int, Void> { [weak localSelf] input in
            return localSelf?.addDigit(input) ?? .empty()
        }
    }()
}

private extension KeypadViewModel {
    func delete() -> Observable<Void> {
        return Observable.create { [weak self] observer in
            if let strongSelf = self {
                strongSelf.currencyValue.value = Currency(strongSelf.currencyValue.value / 10)
                if strongSelf.stringValue.value.isNotEmpty {
                    let string = strongSelf.stringValue.value
                    strongSelf.stringValue.value = string.substring(to: string.index(before: string.endIndex))
                }
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func clear() -> Observable<Void> {
        return Observable.create { [weak self] observer in
            self?.currencyValue.value = 0
            self?.stringValue.value = ""
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func addDigit(_ input: Int) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            if let strongSelf = self {
                let newValue = (10 * strongSelf.currencyValue.value) + Currency(input)
                if (newValue < KeypadViewModelMaxIntegerValue) {
                    strongSelf.currencyValue.value = newValue
                }
                strongSelf.stringValue.value = "\(strongSelf.stringValue.value)\(input)"
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }
}
