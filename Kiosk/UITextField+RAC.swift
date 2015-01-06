import UIKit
import ReactiveCocoa

extension UITextField {
    public func returnKeySignal () -> RACSignal {
        return rac_signalForControlEvents(.EditingDidEndOnExit).takeUntil(rac_willDeallocSignal())
    }
}