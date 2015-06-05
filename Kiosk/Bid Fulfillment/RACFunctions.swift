import Foundation

// Collection of stanardised mapping funtions for RAC work

public func stringIsEmailAddress(text: AnyObject!) -> AnyObject! {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    let testPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    return testPredicate.evaluateWithObject(text)
}

public func centsToPresentableDollarsString(cents:AnyObject!) -> AnyObject! {
    if let cents = cents as? Int {
        if let dollars = NSNumberFormatter.currencyStringForCents(cents) {
            return dollars
        }
    }
    return ""
}

public func isZeroLengthString(string: AnyObject!) -> AnyObject! {
    return count(string as! String) == 0
}

public func isStringLengthIn(range: Range<Int>)(string: AnyObject!) -> AnyObject! {
    return contains(range, count(string as! String))
}

public func isStringOfLength(length: Int)(string: AnyObject!) -> AnyObject! {
    return count(string as! String) == length
}

public func isStringLengthAtLeast(length: Int)(string: AnyObject!) -> AnyObject! {
    return count(string as! String) >= length
}

public func isStringLengthOneOf(lengths: [Int])(string: AnyObject!) -> AnyObject! {
    return contains(lengths, count(string as! String))
}
