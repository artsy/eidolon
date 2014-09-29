import UIKit

extension UIStoryboardSegue {
}

public func ==(lhs: UIStoryboardSegue, rhs: SegueIdentifier) -> Bool {
    return lhs.identifier == rhs.rawValue
}
