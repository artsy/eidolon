import UIKit
import RxSwift

extension UITextField {
    func returnKeySignal () -> RACSignal {
        return rac_signalForControlEvents(.EditingDidEndOnExit).takeUntil(rac_willDeallocSignal())
    }
}