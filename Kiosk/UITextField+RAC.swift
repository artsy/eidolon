import UIKit

extension UITextField {
    public func returnKeySignal () -> RACSignal {
        return rac_signalForControlEvents(.EditingDidEndOnExit).takeUntil(rac_willDeallocSignal())
    }
}