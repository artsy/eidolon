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
    return (string as! String).characters.count == 0
}

public func isStringLengthIn(range: Range<Int>)(string: AnyObject!) -> AnyObject! {
    return range.contains((string as! String).characters.count)
}

public func isStringOfLength(length: Int)(string: AnyObject!) -> AnyObject! {
    return (string as! String).characters.count == length
}

public func isStringLengthAtLeast(length: Int)(string: AnyObject!) -> AnyObject! {
    return (string as! String).characters.count >= length
}

public func isStringLengthOneOf(lengths: [Int])(string: AnyObject!) -> AnyObject! {
    return lengths.contains((string as! String).characters.count)
}
