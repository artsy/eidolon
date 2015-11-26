import UIKit
import RxSwift
import RxCocoa

extension UIView {
    public var rx_hidden: AnyObserver<Bool> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()

            switch event {
            case .Next(let value):
                self?.hidden = value
            case .Error(let error):
//                bindingErrorToInterface(error) // TODO: see https://github.com/ReactiveX/RxSwift/issues/274
                print(error)
                break
            case .Completed:
                break
            }
        }
    }
}

extension UITextField {
    func returnKeySignal() -> Observable<Void> {
        return rx_controlEvents(.EditingDidEndOnExit).takeUntil(rx_deallocating)
    }
}
