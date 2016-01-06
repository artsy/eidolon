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
                bindingErrorToInterface(error)
                break
            case .Completed:
                break
            }
        }
    }
}

extension UITextField {
    var rx_returnKey: Observable<Void> {
        return rx_controlEvent(.EditingDidEndOnExit).takeUntil(rx_deallocating)
    }
}
